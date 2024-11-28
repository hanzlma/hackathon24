//
//  SearchView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import SwiftUI

struct SearchView: View {
    
    
    @State private var isSearched = false
    
    @EnvironmentObject var app: AppData
       
    var body: some View {
        
            if isSearched {
                SearchResultsView(isSearched: $isSearched)
                    .environmentObject(app)
            } else {
                SearchFiltersView(isSearched: $isSearched)
                    .environmentObject(app)
                    
            }
        
    }
    
    
}

#Preview {
    SearchView()
        .environmentObject(AppData())
}
