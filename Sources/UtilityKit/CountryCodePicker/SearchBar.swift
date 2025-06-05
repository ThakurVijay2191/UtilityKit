struct SearchBar: UIViewRepresentable {
    var dismiss: Bool
    var onSearch: (String)->()
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        var parent: SearchBar
        init(_ parent: SearchBar) {
            self.parent = parent
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.onSearch(searchText)
        }
        
        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            return parent.dismiss
        }
    }
}
