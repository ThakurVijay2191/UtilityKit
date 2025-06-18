import SwiftUI
import CoreData
import Combine

struct CountryPicker: View {
    @Binding var isPresented: Bool
    @Binding var selectedCountry: CountryModel?
    @State private var isCountryCodePickerPresented: Bool = false
    @State private var searchPublisher = PassthroughSubject<String, Never>()
    @State private var isKeyboardPresented: Bool = false
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    SearchBar(dismiss: isKeyboardPresented) { searchingText in
                        searchPublisher.send(searchingText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Button("Done") {
                        isPresented = false
                    }
                }
                .padding(.horizontal, 8)
                .padding(.trailing, 12)
                .onReceive(searchPublisher.debounce(for: .seconds(0.45), scheduler: RunLoop.main)) { output in
                    if output.isEmpty {
                        CountryListManager.shared.filteredCountries = CountryListManager.shared.unfilteredCountries
                    } else {
                        let allCountries: [Country] = Countries.countries.filter { $0.name.lowercased().range(of: output.lowercased()) != nil }
                        CountryListManager.shared.filteredCountries = CountryListManager.shared.partionedArray(allCountries, usingSelector: #selector(getter: NSFetchedResultsSectionInfo.name))
                    }
                }
                ScrollViewReader { proxy in
                    List {
                        ForEach(CountryListManager.shared.filteredCountries, id: \.self) { list in
                            if list.count > 0 {
                                Section(list.first?.name.prefix(1) ?? "") {
                                    ForEach(list, id: \.self) { country in
                                        HStack {
                                            Text("\(country.flag) \(country.name)")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text("+\(country.phoneExtension)")
                                        }
                                        .id(country) // <- Important: uniquely identify each row
                                        .contentShape(.rect)
                                        .onTapGesture {
                                            Task { @MainActor in
                                                selectedCountry = getCountryAndName(country.countryCode)
//                                                isPresented = false
                                                print(String(describing: selectedCountry))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .onAppear {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            if let selected = selectedCountry {
                                proxy.scrollTo(selected, anchor: .center)
                            }
                        }
                    }
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        isKeyboardPresented.toggle()
                    }
                }
            }
        }
    }
}

struct TestView: View {
    @State private var selectedCountry: CountryModel?
    @State private var isCountryPickerPresented: Bool = false
    var body: some View {
        Button(selectedCountry?.countryCode ?? "Select Country") {
            isCountryPickerPresented.toggle()
        }
        .countryCodePicker(isPresented: $isCountryPickerPresented, selectedCountry: $selectedCountry)
    }
}

#Preview {
    TestView()
}
