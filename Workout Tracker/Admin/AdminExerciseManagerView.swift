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
            VStack {
                // Button to trigger the JSON upload to Firestore
                Button("Upload JSON to Firestore") {
                    FirestoreService.shared.uploadJSONDataToFirestore()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                // Existing bulk update button
                Button("Run Bulk Update") {
                    FirestoreService.shared.bulkUpdateExerciseNames()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                // New button to match GIFs to exercises
                Button("Match GIFs to Exercises") {
                    FirestoreService.shared.matchGifsToExercises()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)

                List {
                    ForEach(exercises, id: \.id) { exercise in
                        HStack {
                            // Display exercise image or GIF
                            if let gifFileName = exercise.gifFileName,
                               let gifPath = Bundle.main.path(forResource: gifFileName, ofType: nil, inDirectory: "360"),
                               let image = UIImage(contentsOfFile: gifPath) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }

                            VStack(alignment: .leading) {
                                TextField(exercise.name, text: Binding(
                                    get: { editedNames[exercise.id] ?? exercise.name },
                                    set: { editedNames[exercise.id] = $0 }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                                TextField(exercise.bodyPart, text: Binding(
                                    get: { editedBodyParts[exercise.id] ?? exercise.bodyPart },
                                    set: { editedBodyParts[exercise.id] = $0 }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.gray)

                                TextField(exercise.equipment, text: Binding(
                                    get: { editedEquipments[exercise.id] ?? exercise.equipment },
                                    set: { editedEquipments[exercise.id] = $0 }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.gray)
                            }

                            Spacer()

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
                    loadData()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save Changes") {
                            saveSelectedExercises()
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Duplicate Document") {
                            duplicateDocument(from: "user_exercises", to: "user_exercises_4", in: "public")
                        }
                    }
                }
            }
        }
    }

    private func loadData() {
        fetchExercises()
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
        
        saveSelectedExercises()
    }

    private func saveSelectedExercises() {
        let db = Firestore.firestore()
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

    private func duplicateDocument(from sourceDocID: String, to targetDocID: String, in collection: String) {
        let db = Firestore.firestore()
        let sourceDocRef = db.collection(collection).document(sourceDocID)
        let targetDocRef = db.collection(collection).document(targetDocID)
        
        sourceDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
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

// Preview
struct AdminExerciseManagerView_Previews: PreviewProvider {
    static var previews: some View {
        AdminExerciseManagerView()
    }
}




























