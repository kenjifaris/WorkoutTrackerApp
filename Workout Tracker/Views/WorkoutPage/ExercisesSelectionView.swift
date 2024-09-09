//
//  ExercisesSelectionView.swift
//  Workout Tracker
//
//  Created by Kenji  on 9/9/24.
//

import SwiftUI
import FirebaseFirestore // Add this line to fix the "Cannot find 'Firestore'" error


struct ExercisesSelectionView: View {
    // Binding to pass the selected exercises back to ActiveWorkoutView
    @Binding var selectedExercises: [ExerciseModel]

    @State private var exercises: [ExerciseModel] = [] // Load exercises here from Firestore
    @State private var selectedExerciseIDs: Set<String> = Set() // Track selected exercises

    var body: some View {
        NavigationView {
            List {
                ForEach(exercises) { exercise in
                    ExerciseRowView(exercise: exercise)
                        .onTapGesture {
                            toggleSelection(for: exercise)
                        }
                }
            }
            .navigationBarTitle("Select Exercises")
            .navigationBarItems(
                leading: Button("Cancel") {
                    // Dismiss the sheet
                    selectedExercises = []
                },
                trailing: Button("Done") {
                    // Add selected exercises and dismiss
                    selectedExercises = exercises.filter { selectedExerciseIDs.contains($0.id) }
                }
            )
            .onAppear {
                loadExercisesFromFirebase() // Load exercises when the sheet appears
            }
        }
    }

    // Toggle selection of an exercise
    private func toggleSelection(for exercise: ExerciseModel) {
        if selectedExerciseIDs.contains(exercise.id) {
            selectedExerciseIDs.remove(exercise.id)
        } else {
            selectedExerciseIDs.insert(exercise.id)
        }
    }

    // Load exercises from Firestore
    private func loadExercisesFromFirebase() {
        let db = Firestore.firestore()
        let docRef = db.collection("saved_exercises").document("exercisesview_list")
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching exercises: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, let exercisesArray = document.data()?["exercises"] as? [[String: Any]] else {
                print("No exercises found or data is not an array")
                return
            }

            do {
                self.exercises = try exercisesArray.compactMap { dict -> ExerciseModel? in
                    return try? JSONDecoder().decode(ExerciseModel.self, from: JSONSerialization.data(withJSONObject: dict))
                }
            } catch {
                print("Failed to decode exercises: \(error.localizedDescription)")
            }
        }
    }
}
