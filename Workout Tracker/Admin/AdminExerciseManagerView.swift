//
//  AdminExerciseManagerView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/21/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct AdminExerciseManagerView: View {
    @State private var exercises: [ExerciseModel] = []
    @State private var selectedExercises: Set<String> = []
    @State private var editedNames: [String: String] = [:]
    @State private var editedBodyParts: [String: String] = [:]
    @State private var editedEquipments: [String: String] = [:]

    var body: some View {
        NavigationView {
            List {
                ForEach(exercises, id: \.id) { exercise in
                    HStack {
                        // Display exercise image or GIF
                        AsyncImage(url: URL(string: exercise.gifUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            } else if phase.error != nil {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            } else {
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            }
                        }

                        VStack(alignment: .leading) {
                            // Editable text field for exercise name
                            TextField(exercise.name, text: Binding(
                                get: { editedNames[exercise.id] ?? exercise.name },
                                set: { editedNames[exercise.id] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            // Editable text field for body part
                            TextField(exercise.bodyPart, text: Binding(
                                get: { editedBodyParts[exercise.id] ?? exercise.bodyPart },
                                set: { editedBodyParts[exercise.id] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.gray)

                            // Editable text field for equipment
                            TextField(exercise.equipment, text: Binding(
                                get: { editedEquipments[exercise.id] ?? exercise.equipment },
                                set: { editedEquipments[exercise.id] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.gray)
                        }

                        Spacer()

                        // Toggle button to select or deselect exercises
                        Button(action: {
                            toggleSelection(for: exercise)
                        }) {
                            Image(systemName: selectedExercises.contains(exercise.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedExercises.contains(exercise.id) ? .blue : .gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Admin Exercise Manager")
            .onAppear {
                loadSavedExercisesFromFirebase() // Load previously saved selections
                fetchExercises()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Changes") {
                        saveSelectedExercisesToFirebase(exercises.filter { selectedExercises.contains($0.id) })
                    }
                }
            }
        }
    }

    private func fetchExercises() {
        ExerciseDBService().fetchAllExercises { result in
            switch result {
            case .success(let exercises):
                DispatchQueue.main.async {
                    self.exercises = exercises
                }
            case .failure(let error):
                print("Failed to fetch exercises: \(error)")
            }
        }
    }

    private func toggleSelection(for exercise: ExerciseModel) {
        if selectedExercises.contains(exercise.id) {
            selectedExercises.remove(exercise.id)
        } else {
            selectedExercises.insert(exercise.id)
        }
    }

    // This is where you place the saveSelectedExercisesToFirebase function
    private func saveSelectedExercisesToFirebase(_ exercises: [ExerciseModel]) {
        let db = Firestore.firestore()

        do {
            let data = try JSONEncoder().encode(exercises)
            if let exercisesDict = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [[String: Any]] {
                print("Prepared exercises to save: \(exercisesDict)")

                db.collection("selected_exercises").document("user_exercises").setData(["exercises": exercisesDict]) { error in
                    if let error = error {
                        print("Failed to save exercises to Firebase: \(error)")
                    } else {
                        print("Exercises successfully saved to Firebase")
                    }
                }
            } else {
                print("Failed to serialize exercises to dictionary format")
            }
        } catch {
            print("Failed to encode exercises: \(error)")
        }
    }

    private func loadSavedExercisesFromFirebase() {
        let db = Firestore.firestore()

        db.collection("selected_exercises").document("user_exercises").getDocument { document, error in
            if let document = document, document.exists {
                if let exercisesData = document.data()?["exercises"] as? [[String: Any]] {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: exercisesData, options: [])
                        let savedExercises = try JSONDecoder().decode([ExerciseModel].self, from: data)
                        self.selectedExercises = Set(savedExercises.map { $0.id })
                        self.exercises = savedExercises
                    } catch {
                        print("Failed to decode exercises from Firebase: \(error)")
                    }
                }
            } else {
                print("No selected exercises found in Firebase")
            }
        }
    }
}

struct AdminExerciseManagerView_Previews: PreviewProvider {
    static var previews: some View {
        AdminExerciseManagerView()
    }
}











