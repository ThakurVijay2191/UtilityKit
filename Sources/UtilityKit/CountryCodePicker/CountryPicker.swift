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
                List {
                    ForEach(CountryListManager.shared.filteredCountries, id: \.self){ list in
                        if list.count > 0{
                            Section(list.first?.name.prefix(1) ?? "") {
                                ForEach(list, id: \.self){ country in
                                    HStack {
                                        Text("\(country.flag) \(country.name)")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("+\(country.phoneExtension)")
                                    }
                                }
                            }
                        }
                        
                    }
                   
                }
                .listStyle(.plain)
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
