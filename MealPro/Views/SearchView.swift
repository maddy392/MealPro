//
//  SearchView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 3/2/25.
//
import SwiftUI

struct SearchView: View {
    
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchResults) { recipe in
                    WideRecipeView(recipe: recipe)
//                        .listRowSeparator(.hidden, edges: .all)
                        .listRowInsets(EdgeInsets(top: 2.5, leading: 0, bottom: 2.5, trailing: 0))
                }
            }
            .listStyle(.plain)
            .navigationTitle("Search")
            .searchable(text: $viewModel.searchText, prompt: "Search")
            .onSubmit(of: .search) {
                Task {
                     await viewModel.searchRecipes()
                }
            }
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(FavoriteViewModel.shared)
}
