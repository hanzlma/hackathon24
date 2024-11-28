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
        
        ZStack {
            if isSearched {
                SearchResultsView(isSearched: $isSearched)
                    .environmentObject(app)
                    .transition(.move(edge: .trailing)) //.bottom
            } else {
                SearchFiltersView(isSearched: $isSearched)
                    .environmentObject(app)
                    .transition(.move(edge: .leading)) // .top
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isSearched) // Smooth animation

        
    }
    
    
}

#Preview {
    SearchView()
        .environmentObject(AppData())
}
