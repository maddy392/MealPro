//
//  AuthController.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/11/24.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

class AuthController: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    
    func checkAuthStatus() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            await MainActor.run {
                self.isAuthenticated = session.isSignedIn
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("Failed to check Auth Status \(error)")
        }
    }
    
    func signOut() async {
        let result = await Amplify.Auth.signOut()
        guard let signOutResult = result as? AWSCognitoSignOutResult else {
            print("Signout Failed!")
            return
        }
        
        switch signOutResult {
        case .complete:
            await MainActor.run {
                self.isAuthenticated = false
            }
        case .partial(_,_,_):
            print("Partial sign out completed")
        case .failed(let error):
            print("Sign out failed with \(error)")
        }
    }
}
