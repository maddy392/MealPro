//
//  FavoriteRecipesView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/12/24.
//

import SwiftUI
import Amplify

struct FavoriteRecipesView: View {
    @EnvironmentObject private var favoriteViewModel: FavoriteViewModel

    var body: some View {
        Group {
            if favoriteViewModel.userFavorites.isEmpty {
                Text("No favorite recipes yet!")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(favoriteViewModel.userFavorites, id: \.id) { favoriteItem in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(favoriteItem.recipe.title)
                                    .font(.headline)
                                if let imageUrl = favoriteItem.recipe.image, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await favoriteViewModel.fetchUserFavorites()
            }
        }
//        .navigationTitle("Favorite Recipes")
    }
}
