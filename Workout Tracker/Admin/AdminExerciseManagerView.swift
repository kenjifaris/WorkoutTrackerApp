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
                loadData() // Fetch exercises and selections
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Changes") {
                        saveSelectedExercises() // Save the changes directly to Firestore
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Duplicate Document") {
                        // Example of duplicating the "user_exercises" document with a new ID
                        duplicateDocument(from: "user_exercises", to: "user_exercises_1", in: "public")
                    }
                }
            }
        }
    }

    private func loadData() {
        // Fetch exercises from API
        fetchExercises()

        // Fetch selected exercises from Firestore
        fetchSelectedExercises()
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

    private func fetchSelectedExercises() {
        let db = Firestore.firestore()
        let docRef = db.collection("public").document("user_exercises")

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(), let savedExercises = data["exercises"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.selectedExercises = Set(savedExercises.compactMap { $0["id"] as? String })
                    }
                }
            } else {
                print("No document found or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func toggleSelection(for exercise: ExerciseModel) {
        if selectedExercises.contains(exercise.id) {
            selectedExercises.remove(exercise.id)
        } else {
            selectedExercises.insert(exercise.id)
        }
        
        // Save immediately after toggling
        saveSelectedExercises()
    }

    private func saveSelectedExercises() {
        let db = Firestore.firestore()

        // Prepare data to save
        let selectedExerciseModels = exercises.filter { selectedExercises.contains($0.id) }
        do {
            let data = try JSONEncoder().encode(selectedExerciseModels)
            if let exercisesDict = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [[String: Any]] {
                db.collection("public").document("user_exercises").setData(["exercises": exercisesDict]) { error in
                    if let error = error {
                        print("Failed to save exercises to Firebase: \(error)")
                    } else {
                        print("Exercises successfully saved to Firebase")
                    }
                }
            }
        } catch {
            print("Failed to encode exercises: \(error)")
        }
    }

    // Function to duplicate a document
    private func duplicateDocument(from sourceDocID: String, to targetDocID: String, in collection: String) {
        let db = Firestore.firestore()
        let sourceDocRef = db.collection(collection).document(sourceDocID)
        let targetDocRef = db.collection(collection).document(targetDocID)
        
        sourceDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Get the data from the source document
                if let data = document.data() {
                    // Set the data to the target document
                    targetDocRef.setData(data) { error in
                        if let error = error {
                            print("Error duplicating document: \(error.localizedDescription)")
                        } else {
                            print("Document successfully duplicated!")
                        }
                    }
                }
            } else {
                print("Source document does not exist or failed to fetch: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

struct AdminExerciseManagerView_Previews: PreviewProvider {
    static var previews: some View {
        AdminExerciseManagerView()
    }
}





















