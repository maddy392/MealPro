//
//  SearchView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 3/2/25.
//
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel() // 🔹 ViewModel

    var body: some View {
        NavigationStack {
            SearchingView(viewModel: viewModel)
                .searchable(text: $viewModel.searchText, prompt: "Search Recipes")
                .onSubmit(of: .search) {
                    Task {
                        await viewModel.searchRecipes()
                    }
                }
        }
    }
}

struct SearchingView: View {
    @Environment(\.isSearching) private var isSearching  // Detect search field activation
    @Environment(\.dismissSearch) private var dismissSearch  // Allows dismissing search field
    @ObservedObject var viewModel: SearchViewModel  // 🔹 ViewModel

    var body: some View {
        List {
            // 🔹 Show Recent Searches ONLY when searchText is empty and search is active
            if isSearching && viewModel.searchText.isEmpty {
                Section(header: Text("Recent Searches").font(.subheadline).foregroundColor(.gray)) {
                    ForEach(viewModel.recentSearches, id: \.id) { search in
                        Text(search.query)
                            .onTapGesture {
                                viewModel.searchText = search.query
                                Task {
                                    await viewModel.searchRecipes()
                                    dismissSearch()  // Hide search bar
                                }
                            }
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.fetchRecentSearches()
                    }
                }
            }

            // 🔹 Always show Search Results (if available)
            if !viewModel.searchResults.isEmpty {
                Section {
                    ForEach(viewModel.searchResults) { recipe in
                        WideRecipeView(recipe: recipe)
                            .listRowInsets(EdgeInsets(top: 2.5, leading: 0, bottom: 2.5, trailing: 0))
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Search")
    }
}

#Preview {
    SearchView()
        .environmentObject(FavoriteViewModel.shared)
}
