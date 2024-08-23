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
                                set: {
                                    editedNames[exercise.id] = $0
                                    print("Editing \(exercise.id): Name updated to \($0)")  // Debugging print statement
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            // Editable text field for body part
                            TextField(exercise.bodyPart, text: Binding(
                                get: { editedBodyParts[exercise.id] ?? exercise.bodyPart },
                                set: {
                                    editedBodyParts[exercise.id] = $0
                                    print("Editing \(exercise.id): Body part updated to \($0)")  // Debugging print statement
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.gray)

                            // Editable text field for equipment
                            TextField(exercise.equipment, text: Binding(
                                get: { editedEquipments[exercise.id] ?? exercise.equipment },
                                set: {
                                    editedEquipments[exercise.id] = $0
                                    print("Editing \(exercise.id): Equipment updated to \($0)")  // Debugging print statement
                                }
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
                loadSavedExercises() // Load exercises from JSON
                fetchExercises() // Optionally fetch additional exercises from API
                
                printDocumentsDirectoryPath() // Print the Documents directory path
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Changes") {
                        saveSelectedExercises() // Save the changes to Firestore
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

    // Function to save edited and selected exercises to Firestore
    private func saveSelectedExercises() {
        // Apply edited names, body parts, and equipment
        for (id, newName) in editedNames {
            if let index = exercises.firstIndex(where: { $0.id == id }) {
                exercises[index].name = newName
                print("Applied edit: Updated \(exercises[index].id) name to \(newName)")  // Debugging print statement
            }
        }
        for (id, newBodyPart) in editedBodyParts {
            if let index = exercises.firstIndex(where: { $0.id == id }) {
                exercises[index].bodyPart = newBodyPart
                print("Applied edit: Updated \(exercises[index].id) body part to \(newBodyPart)")  // Debugging print statement
            }
        }
        for (id, newEquipment) in editedEquipments {
            if let index = exercises.firstIndex(where: { $0.id == id }) {
                exercises[index].equipment = newEquipment
                print("Applied edit: Updated \(exercises[index].id) equipment to \(newEquipment)")  // Debugging print statement
            }
        }

        // Filter out unselected exercises
        let finalExercises = exercises.filter { selectedExercises.contains($0.id) }

        // Save `finalExercises` to Firestore
        saveExercisesToFirebase(finalExercises)
    }

    // Function to save exercises to Firestore
    private func saveExercisesToFirebase(_ exercises: [ExerciseModel]) {
        let db = Firestore.firestore()

        do {
            let data = try JSONEncoder().encode(exercises)
            if let exercisesDict = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [[String: Any]] {
                print("Prepared exercises to save: \(exercisesDict)")  // Debugging print statement
                db.collection("public").document("user_exercises").setData(["exercises": exercisesDict]) { error in
                    if let error = error {
                        print("Failed to save exercises to Firebase: \(error)")
                    } else {
                        print("Exercises successfully saved to Firebase")
                        // Fetch immediately after saving to verify
                        fetchSavedExercisesFromFirebase()
                    }
                }
            } else {
                print("Failed to serialize exercises to dictionary format")
            }
        } catch {
            print("Failed to encode exercises: \(error)")
        }
    }

    private func fetchSavedExercisesFromFirebase() {
        let db = Firestore.firestore()

        db.collection("public").document("user_exercises").getDocument { document, error in
            if let document = document, document.exists {
                print("Document data: \(document.data() ?? [:])")
            } else {
                print("Document does not exist")
            }
        }
    }

    private func loadSavedExercises() {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("selected_exercises.json")
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let savedExercises = try decoder.decode([ExerciseModel].self, from: data)
                self.selectedExercises = Set(savedExercises.map { $0.id })
                self.exercises = savedExercises
                print("Loaded saved exercises from \(fileURL)")
            } catch {
                print("Failed to load saved exercises: \(error)")
            }
        }
    }

    // Function to print the path to the Documents directory
    private func printDocumentsDirectoryPath() {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Documents Directory Path: \(documentsDirectory.path)")
        }
    }
}

struct AdminExerciseManagerView_Previews: PreviewProvider {
    static var previews: some View {
        AdminExerciseManagerView()
    }
}
















