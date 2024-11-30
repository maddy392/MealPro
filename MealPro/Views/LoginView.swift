//
//  LoginView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/11/24.
//

import SwiftUI
import Amplify
import Authenticator

struct LoginView: View {
    @StateObject private var authController = AuthController()
    
    var body: some View {
        Group {
            if authController.isLoading {
                ProgressView("Checking Authentication Status...")
            } else if authController.isAuthenticated {
                ContentView()
                    .environmentObject(authController)
                    .environmentObject(FavoriteViewModel.shared)
            } else {
                Authenticator { _ in
                    Color.clear.onAppear {
                        Task {
                            await authController.checkAuthStatus()
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await authController.checkAuthStatus()
            }
        }
    }
}
