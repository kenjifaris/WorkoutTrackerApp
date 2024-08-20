//
//  SearchBarView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/20/24.
//

import SwiftUI

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var onTextChanged: (String) -> Void

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var onTextChanged: (String) -> Void

        init(text: Binding<String>, onTextChanged: @escaping (String) -> Void) {
            _text = text
            self.onTextChanged = onTextChanged
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            onTextChanged(searchText)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, onTextChanged: onTextChanged)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}


