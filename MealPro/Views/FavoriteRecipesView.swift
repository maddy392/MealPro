//
//  FavoriteRecipesView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/12/24.
//

import SwiftUI
import Amplify

struct FavoriteRecipesView: View {
    @StateObject private var favoriteViewModel = FavoriteViewModel()
    
    var body: some View {
        Text("Hello World")
//        List {
//            ForEach(favoriteViewModel.favoriteRecipes) { recipe in
//                HStack {
//                    Text(recipe.title)
//                    AsyncImage(url: URL(string: recipe.image!)) { image in
//                        image
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 100)
//                    } placeholder: {
//                        ProgressView()
//                    }
//                }
//            }
//        }
//        .onAppear {
//            Task {
//                await favoriteViewModel.subscribeToFavoriteChanges()
//            }
//        }
//        .onDisappear {
//            favoriteViewModel.cancelSubscription()
//        }
    }
}
