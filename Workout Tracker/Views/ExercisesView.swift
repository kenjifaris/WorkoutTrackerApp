//
//  ExercisesView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ExercisesView: View {
    @State private var exercises: [ExerciseModel] = []
    @State private var filteredExercises: [ExerciseModel] = []
    @State private var searchText: String = ""
    @State private var selectedBodyPart: String? = nil
    @State private var selectedEquipment: String? = nil
    @State private var selectedExercises: [ExerciseModel] = []
    @State private var isLoading = false
    @State private var selectedExercise: ExerciseModel?

    // State to manage sheet presentation
    @State private var isBodyPartSheetPresented = false
    @State private var isEquipmentSheetPresented = false
    @State private var bodyParts: [String] = []
    @State private var equipments: [String] = []

    // Mapping dictionaries to condense categories
    private let equipmentMapping: [String: String] = [
        "Elliptical Machine": "Machine",
        "Leverage Machine": "Machine",
        "Sled Machine": "Machine",
        "Stepmill Machine": "Machine",
        "Stationary Bike": "Machine",
        "Hammer": "Other",
        "Trap Bar": "Other",
        "Rope": "Other",
        "Wheel Roller": "Other",
        // Add more mappings as needed
    ]
    
    private let bodyPartMapping: [String: String] = [
        "Lower Legs": "Legs",
        "Upper Legs": "Legs",
        "Lower Arms": "Arms",
        "Upper Arms": "Arms",
        "Waist": "Core", // Map 'waist' to 'core'
        // Add more mappings as needed
    ]

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText, onTextChanged: filterExercises)
                    .padding(.top)

                // Filter Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        fetchBodyParts()
                    }) {
                        Text(selectedBodyPart ?? "Any Body Part")
                            .font(.subheadline)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $isBodyPartSheetPresented) {
                        List {
                            Button("Any Body Part") {
                                selectedBodyPart = nil
                                filterExercises(searchText)
                                isBodyPartSheetPresented = false
                            }
                            ForEach(bodyParts, id: \.self) { part in
                                Button(part) {
                                    selectedBodyPart = part
                                    filterExercises(searchText)
                                    isBodyPartSheetPresented = false
                                }
                            }
                        }
                    }

                    Button(action: {
                        fetchEquipments()
                    }) {
                        Text(selectedEquipment ?? "Any Equipment")
                            .font(.subheadline)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $isEquipmentSheetPresented) {
                        List {
                            Button("Any Equipment") {
                                selectedEquipment = nil
                                filterExercises(searchText)
                                isEquipmentSheetPresented = false
                            }
                            ForEach(equipments, id: \.self) { equipment in
                                Button(equipment) {
                                    selectedEquipment = equipment
                                    filterExercises(searchText)
                                    isEquipmentSheetPresented = false
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Exercise List
                List(filteredExercises) { exercise in
                    HStack {
                        ExerciseRowView(exercise: exercise)

                        Spacer()

                        // Info button to view exercise details
                        Button(action: {
                            selectedExercise = exercise
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
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
                loadExercisesFromFirebase()
            }
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
    }

    private func fetchBodyParts() {
        let db = Firestore.firestore()
        db.collection("public").document("user_exercises_2").getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data(), let exercisesArray = data["exercises"] as? [[String: Any]] {
                    var bodyPartsSet = Set<String>()
                    for bodyPart in exercisesArray.compactMap({ $0["bodyPart"] as? String }) {
                        let mappedBodyPart = bodyPartMapping[bodyPart] ?? bodyPart
                        bodyPartsSet.insert(mappedBodyPart)
                    }
                    DispatchQueue.main.async {
                        self.bodyParts = Array(bodyPartsSet).sorted()
                        self.isBodyPartSheetPresented = true // Show sheet after fetching data
                    }
                }
            } else {
                print("Failed to fetch body parts: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func fetchEquipments() {
        let db = Firestore.firestore()
        db.collection("public").document("user_exercises_2").getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data(), let exercisesArray = data["exercises"] as? [[String: Any]] {
                    var equipmentsSet = Set<String>()
                    for equipment in exercisesArray.compactMap({ $0["equipment"] as? String }) {
                        let mappedEquipment = equipmentMapping[equipment] ?? equipment
                        equipmentsSet.insert(mappedEquipment)
                    }
                    DispatchQueue.main.async {
                        self.equipments = Array(equipmentsSet).sorted()
                        self.isEquipmentSheetPresented = true // Show sheet after fetching data
                    }
                }
            } else {
                print("Failed to fetch equipment: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func filterExercises(_ text: String) {
        filteredExercises = exercises.filter { exercise in
            let mappedBodyPart = bodyPartMapping[exercise.bodyPart] ?? exercise.bodyPart
            let mappedEquipment = equipmentMapping[exercise.equipment] ?? exercise.equipment
            let matchesBodyPart = selectedBodyPart == nil || mappedBodyPart == selectedBodyPart
            let matchesEquipment = selectedEquipment == nil || mappedEquipment == selectedEquipment
            let matchesText = text.isEmpty || exercise.name.lowercased().contains(text.lowercased())

            return matchesBodyPart && matchesEquipment && matchesText
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

    private func loadExercisesFromFirebase() {
        let db = Firestore.firestore()

        db.collection("public").document("user_exercises_2").getDocument { document, error in
            if let document = document, document.exists {
                do {
                    if let data = document.data(),
                       let exercisesArray = data["exercises"] as? [[String: Any]] {
                        let jsonData = try JSONSerialization.data(withJSONObject: exercisesArray, options: [])
                        let exercises = try JSONDecoder().decode([ExerciseModel].self, from: jsonData)
                        DispatchQueue.main.async {
                            self.exercises = exercises
                            self.filteredExercises = exercises
                        }
                    } else {
                        print("No exercises found in Firebase")
                    }
                } catch {
                    print("Failed to decode exercises: \(error)")
                }
            } else {
                print("Document does not exist or failed to fetch: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

// Preview for ExercisesView
struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
    }
}
























































