
@MainActor
@Observable
fileprivate final class CountryListManager {
    static let shared = CountryListManager()
    fileprivate init () {
        setupCountries()
    }
    var unfilteredCountries: [[Country]] = [] { didSet {
        filteredCountries = unfilteredCountries
        
    } }
    var filteredCountries: [[Country]] = []
    var majorCountryLocaleIdentifiers: [String] = []

    fileprivate func setupCountries() {

        unfilteredCountries = partionedArray(Countries.countries, usingSelector: #selector(getter: NSFetchedResultsSectionInfo.name))
        unfilteredCountries.insert(Countries.countriesFromCountryCodes(majorCountryLocaleIdentifiers), at: 0)
    }
    
    func partionedArray<T: AnyObject>(_ array: [T], usingSelector selector: Selector) -> [[T]] {

    let collation = UILocalizedIndexedCollation.current()
    let numberOfSectionTitles = collation.sectionTitles.count
    var unsortedSections: [[T]] = Array(repeating: [], count: numberOfSectionTitles)

    for object in array {
        let sectionIndex = collation.section(for: object, collationStringSelector: selector)
        unsortedSections[sectionIndex].append(object)
    }

    var sortedSections: [[T]] = []

    for section in unsortedSections {
        let sortedSection = collation.sortedArray(from: section, collationStringSelector: selector) as! [T]
        sortedSections.append(sortedSection)
    }

    return sortedSections

}
}