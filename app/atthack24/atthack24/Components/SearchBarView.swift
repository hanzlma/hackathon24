//
//  SearchBarView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//


import SwiftUI

struct SearchBarView: View {
    @State private var searchText: String = ""
    private let words = ["Station1", "Station2", "Brno"]
    @State private var suggestions: [String] = []
    
    var body: some View {
        VStack {
            TextField("Search...", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onChange(of: searchText) { newValue in
                    updateSuggestions(for: newValue)
                }
            
            List(suggestions, id: \.self) { suggestion in
                Text(suggestion)
                    .onTapGesture {
                        searchText = suggestion
                        suggestions = []
                    }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
    }
    
    private func updateSuggestions(for input: String) {
        if input.isEmpty {
            suggestions = []
        } else {
            suggestions = words.filter { $0.lowercased().contains(input.lowercased()) }
        }
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView()
    }
}
