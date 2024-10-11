//
//  ContentView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authController: AuthController
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
            .toolbar {
                Button("Sign Out") {
                    Task {
                        await authController.signOut()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
