//
//  Workout_TrackerApp.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct WorkoutTrackerApp: App {
    init() {
        FirebaseApp.configure()
        signInAnonymouslyForTesting() // Call sign-in during app initialization
    }

    var body: some Scene {
        WindowGroup {
            ContentView() // Your initial view
        }
    }
}

func signInAnonymouslyForTesting() {
    Auth.auth().signInAnonymously { authResult, error in
        if let error = error {
            print("Error during anonymous sign-in: \(error.localizedDescription)")
            return
        }
        if let user = authResult?.user {
            print("Anonymous sign-in successful. User ID: \(user.uid)")
        }
    }
}




