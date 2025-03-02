//
//  MealProApp.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/11/24.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSPinpointAnalyticsPlugin

@main
struct MealProApp: App {
    
    init() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSPinpointAnalyticsPlugin())
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels()))
            try Amplify.configure(with: .amplifyOutputs)
            print("Amplify configuration success !")
        } catch {
            print("Unable to configure Amplify \(error)")
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
