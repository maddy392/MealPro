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
    @Published var userId: String = ""
    @Published var username: String = ""
    @Published var email: String = ""

    static let shared = AuthController()

    func checkAuthStatus() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if session.isSignedIn {
                let currentUser = try await Amplify.Auth.getCurrentUser()
                let attributes = try await Amplify.Auth.fetchUserAttributes()
                let userEmail = attributes.first(where: { $0.key == .email })?.value ?? "No email"

                await MainActor.run {
                    self.userId = currentUser.userId
                    self.username = currentUser.username
                    self.email = userEmail
                    self.isAuthenticated = true
                    self.isLoading = false
                }

                await createUserIfNotExists(userId: currentUser.userId, username: currentUser.username, email: userEmail)
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
            print("❌ Failed to check Auth Status: \(error)")
        }
    }

    private func createUserIfNotExists(userId: String, username: String, email: String) async {
        do {
            let userResponse = try await Amplify.API.query(request: .get(User.self, byIdentifier: .identifier(userId: userId))).get()
            if userResponse == nil {
                let newUser = User(userId: userId, username: username)
                let result = try await Amplify.API.mutate(request: .create(newUser))
                switch result {
                case .success(let createdUser):
                    print("✅ Created new user: \(createdUser.username)")
                case .failure(let error):
                    print("❌ Failed to create user: \(error.errorDescription)")
                }
            } else {
                print("ℹ️ User already exists in the database")
            }
        } catch let error as APIError {
            print("❌ Failed to create User: ", error)
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }

    func signOut() async {
        let result = await Amplify.Auth.signOut()
        guard let signOutResult = result as? AWSCognitoSignOutResult else {
            print("❌ Signout Failed!")
            return
        }

        switch signOutResult {
        case .complete:
            await MainActor.run {
                self.isAuthenticated = false
                self.userId = ""
                self.username = ""
                self.email = ""
            }
            print("✅ Signed out successfully")
        case .partial(_, _, _):
            print("⚠️ Partial sign out completed")
        case .failed(let error):
            print("❌ Sign out failed with \(error)")
        }
    }
}
