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
    private var userId: String?
    private var username: String?
    
    func checkAuthStatus() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if session.isSignedIn {
                let currentUser = try await Amplify.Auth.getCurrentUser()
                self.userId = currentUser.userId
                self.username = currentUser.username
                
                await createUserIfNotExists(userId: currentUser.userId, username: currentUser.username)
                
                await MainActor.run {
                    self.isAuthenticated = session.isSignedIn
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.isAuthenticated = false
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("Failed to check Auth Status \(error)")
        }
    }
    
    private func createUserIfNotExists(userId: String, username: String) async {
        
        do {
            let userResponse = try await Amplify.API.query(request: .get(User.self, byIdentifier: .identifier(userId: userId))).get()
            if userResponse == nil {
                let newUser = User(userId: userId, username: username)
                let result = try await Amplify.API.mutate(request: .create(newUser))
                switch result {
                case .success(let createdUser):
                    print("Created new user: \(createdUser.username)")
                case .failure(let error):
                    print("Failed to create user: \(error.errorDescription)")
                }
            } else {
                print("User already exists in the database")
            }
        } catch let error as APIError {
            print("Failed to create User: ", error)
        } catch {
            print("Unexpected error: \(error)")
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
