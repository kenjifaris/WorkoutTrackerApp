//
//  ActiveWorkoutView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI



struct ActiveWorkoutView: View {
    @State private var workoutName: String = "Afternoon Workout"
    @State private var workoutDuration: TimeInterval = 0
    @State private var selectedExercises: [ExerciseModel] = [] // To store selected exercises
    @State private var isExercisesViewPresented = false

    // Timer to keep track of workout duration
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Timer and Title Row
            HStack {
                Button(action: {
                    // Add functionality for the timer button
                }) {
                    Image(systemName: "timer")
                        .font(.title)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Spacer()
                
                Text(workoutName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    // Add functionality to finish workout
                }) {
                    Text("Finish")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            Text("\(formatTime(workoutDuration))")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Notes")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Display selected exercises
            List(selectedExercises) { exercise in
                ExerciseRowView(exercise: exercise)
            }

            // Add Exercises Button
            Button(action: {
                isExercisesViewPresented = true
            }) {
                Text("Add Exercises")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .sheet(isPresented: $isExercisesViewPresented) {
                // Present ExercisesView and pass back selected exercises
                ExercisesSelectionView(selectedExercises: $selectedExercises)
            }
            
            // Cancel Workout Button
            Button(action: {
                // Add functionality to cancel the workout
            }) {
                Text("Cancel Workout")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        .navigationTitle("")
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            workoutDuration += 1
        }
    }
    
    // Format Time Interval into H:MM:SS format
    private func formatTime(_ totalSeconds: TimeInterval) -> String {
        let seconds = Int(totalSeconds) % 60
        let minutes = (Int(totalSeconds) / 60) % 60
        let hours = Int(totalSeconds) / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}



