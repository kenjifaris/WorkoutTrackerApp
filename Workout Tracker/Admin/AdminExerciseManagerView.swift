//
//  AdminExerciseManagerView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/21/24.
//

import SwiftUI

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
                loadSavedExercises() // Load previously saved selections
                fetchExercises()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Changes") {
                        saveSelectedExercises()
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

    private func saveSelectedExercises() {
        // Apply edited names, body parts, and equipment
        for (id, newName) in editedNames {
            if let index = exercises.firstIndex(where: { $0.id == id }) {
                exercises[index].name = newName
            }
        }
        for (id, newBodyPart) in editedBodyParts {
            if let index = exercises.firstIndex(where: { $0.id == id }) {
                exercises[index].bodyPart = newBodyPart
            }
        }
        for (id, newEquipment) in editedEquipments {
            if let index = exercises.firstIndex(where: { $0.id == id }) {
                exercises[index].equipment = newEquipment
            }
        }

        // Filter out unselected exercises
        let finalExercises = exercises.filter { selectedExercises.contains($0.id) }

        // Save `finalExercises` to a JSON file
        saveExercisesToLocalStorage(finalExercises)
    }

    private func saveExercisesToLocalStorage(_ exercises: [ExerciseModel]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(exercises)
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("selected_exercises.json")
                try data.write(to: fileURL)
                print("Exercises saved to \(fileURL)")
            }
        } catch {
            print("Failed to save exercises: \(error)")
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
}

struct AdminExerciseManagerView_Previews: PreviewProvider {
    static var previews: some View {
        AdminExerciseManagerView()
    }
}








