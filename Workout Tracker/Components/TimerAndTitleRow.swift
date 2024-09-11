//
//  TimerAndTitleRow.swift
//  Workout Tracker
//
//  Created by Kenji  on 9/11/24.
//

import SwiftUI

struct TimerAndTitleRow: View {
    @Binding var isTimerRunning: Bool
    @Binding var workoutName: String
    @Binding var workoutDuration: TimeInterval
    @Binding var showingWorkoutOptions: Bool
    @Binding var isEditingWorkoutName: Bool
    @Binding var newWorkoutName: String

    var toggleTimer: () -> Void
    var finishWorkout: () -> Void

    var body: some View {
        HStack {
            // Timer button to start/stop
            Button(action: {
                toggleTimer()
            }) {
                Image(systemName: isTimerRunning ? "pause.circle" : "play.circle")
                    .font(.title)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }

            Spacer()

            // Workout name and formatted timer
            VStack(alignment: .leading) {
                HStack {
                    Text(workoutName)
                        .font(.title)
                        .fontWeight(.bold)

                    // Add ellipsis next to the workout name
                    Button(action: {
                        showingWorkoutOptions = true // Show workout options
                    }) {
                        Image(systemName: "ellipsis")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    .contentShape(Rectangle())  // Make the entire area tappable
                }

                Text("\(formatTime(workoutDuration))")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Notes")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Finish workout button
            Button(action: {
                finishWorkout()
            }) {
                Text("Finish")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }

    // Helper to format time
    private func formatTime(_ totalSeconds: TimeInterval) -> String {
        let seconds = Int(totalSeconds) % 60
        let minutes = (Int(totalSeconds) / 60) % 60
        let hours = Int(totalSeconds) / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}



