import SwiftUI

public extension View {
    @ViewBuilder
    func countryCodePicker(isPresented: Binding<Bool>, selectedCountry: Binding<CountryModel?>)-> some View {
        self
            .sheet(isPresented: isPresented) {
                CountryPicker(country: selectedCountry)
            }
    }
}

fileprivate struct CountryPicker: UIViewControllerRepresentable {
    let countryPicker = CountriesViewController()
    @Binding var country: CountryModel?
    
    public func makeUIViewController(context: Context) -> CountriesViewController {
        countryPicker.allowMultipleSelection = false
        countryPicker.delegate = context.coordinator
        countryPicker.selectedCountry = country
        return countryPicker
    }
    
    public func updateUIViewController(_ uiViewController: CountriesViewController, context: Context) {
        countryPicker.selectedCountry = country
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: NSObject, @preconcurrency CountriesViewControllerDelegate {
        public func countriesViewControllerDidCancel(_ countriesViewController: CountriesViewController) {
        }
        
        @MainActor public func countriesViewController(_ countriesViewController: CountriesViewController, didSelectCountry country: Country) {
            let cModel = CountryModel()
            if let info = getCountryAndName(country.countryCode) {
                cModel.countryCode  = info.countryCode!
                cModel.countryFlag  = info.countryFlag!
            }
            parent.country = cModel
        }
        
        public func countriesViewController(_ countriesViewController: CountriesViewController, didUnselectCountry country: Country) {
        }
        
        public func countriesViewController(_ countriesViewController: CountriesViewController, didSelectCountries countries: [Country]) {
        }
        
        var parent: CountryPicker
        init(_ parent: CountryPicker) {
            self.parent = parent
        }
    }
}
