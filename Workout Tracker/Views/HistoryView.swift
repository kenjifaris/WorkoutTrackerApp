//
//  HistoryView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

// HistoryView.swift

import SwiftUI
import FirebaseAuth // Make sure FirebaseAuth is imported for userId retrieval

struct HistoryView: View {
    @State private var userWorkouts: [Workout] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Workouts...")
                } else if userWorkouts.isEmpty {
                    Text("No workout history available. Start tracking your workouts!")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(userWorkouts) { workout in
                        // Display each workout (you can customize this list item as you like)
                        VStack(alignment: .leading) {
                            Text(workout.workoutName)
                                .font(.headline)
                            Text("Duration: \(formatTimeInterval(workout.workoutDuration))")
                                .font(.subheadline)
                            Text("Exercise Count: \(workout.exerciseSets.count)")
                                .font(.subheadline)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Workout History")
            .onAppear {
                fetchWorkouts()
            }
        }
    }
    
    // MARK: - Fetch Workouts
    private func fetchWorkouts() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return
        }
        
        FirestoreService.shared.fetchUserWorkouts(for: userId) { result in
            switch result {
            case .success(let workouts):
                self.userWorkouts = workouts
                self.isLoading = false
            case .failure(let error):
                print("Failed to fetch workouts: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Helper to format time
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}






