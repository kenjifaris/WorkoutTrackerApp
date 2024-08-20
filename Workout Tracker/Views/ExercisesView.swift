//
//  ExercisesView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct ExercisesView: View {
    @State private var exercises: [ExerciseModel] = []
    @State private var filteredExercises: [ExerciseModel] = []
    @State private var searchText: String = ""
    @State private var selectedBodyPart: String? = nil
    @State private var selectedExercises: [ExerciseModel] = []
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onTextChanged: filterExercises)
                    .padding(.top)
                
                // Exercise List
                List(filteredExercises) { exercise in
                    HStack {
                        ExerciseRowView(exercise: exercise)
                        
                        Spacer()
                        
                        // Add button
                        Button(action: {
                            addExercise(exercise)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                    }
                    .padding(.vertical, 5)
                }

                // Selected Exercises Summary
                if !selectedExercises.isEmpty {
                    HStack {
                        Text("Selected: \(selectedExercises.count) Exercises")
                            .font(.headline)
                        Spacer()
                        Button(action: finalizeWorkout) {
                            Text("Finalize")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                }
            }
            .navigationTitle("Exercises")
            .onAppear {
                loadExercises()
            }
        }
    }

    private func filterExercises(_ text: String) {
        filteredExercises = exercises.filter { exercise in
            (selectedBodyPart == nil || exercise.bodyPart == selectedBodyPart) &&
            (text.isEmpty || exercise.name.lowercased().contains(text.lowercased()))
        }
    }

    private func addExercise(_ exercise: ExerciseModel) {
        if !selectedExercises.contains(exercise) {
            selectedExercises.append(exercise)
        }
    }

    private func finalizeWorkout() {
        // Navigate to a summary page or perform the desired action
    }

    private func loadExercises() {
        isLoading = true
        ExerciseDBService().fetchAllExercises { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let exercises):
                    self.exercises = exercises
                    self.filteredExercises = exercises
                case .failure(let error):
                    print("Failed to load exercises: \(error)")
                }
            }
        }
    }
}










































