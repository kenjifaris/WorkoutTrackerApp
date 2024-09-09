//
//  ExercisesSelectionView.swift
//  Workout Tracker
//
//  Created by Kenji  on 9/9/24.
//

import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct ExercisesSelectionView: View {
    // Binding to pass the selected exercises back to ActiveWorkoutView
    @Binding var selectedExercises: [ExerciseModel]
    
    // Completion handler to notify when exercises are added
    var onAdd: (() -> Void)? // New completion closure

    @State private var exercises: [ExerciseModel] = []
    @State private var filteredExercises: [ExerciseModel] = []
    @State private var searchText: String = ""
    @State private var selectedBodyPart: String? = nil
    @State private var selectedEquipment: String? = nil
    @State private var selectedSplit: String? = nil

    // State to manage sheet presentation
    @State private var isBodyPartSheetPresented = false
    @State private var isEquipmentSheetPresented = false
    @State private var isSplitSheetPresented = false
    @State private var bodyParts: [String] = []
    @State private var equipments: [String] = []
    @State private var selectedExercise: ExerciseModel? = nil // To show ExerciseDetailView

    // Mapping dictionaries to condense categories
    private let equipmentMapping: [String: String] = [
        "Elliptical Machine": "Machine",
        "Leverage Machine": "Machine",
        "Sled Machine": "Machine",
        "Stepmill Machine": "Machine",
        "Rope": "Other",
        "Trap Bar": "Other",
        "Body Weight": "Other"
    ]
    
    private let bodyPartMapping: [String: String] = [
        "Lower Legs": "Legs",
        "Upper Legs": "Legs",
        "Lower Arms": "Arms",
        "Upper Arms": "Arms",
        "Waist": "Core"
    ]
    
    private let splitMapping: [String: [String]] = [
        "Push": ["Pectorals", "Shoulders", "Triceps", "Delts", "Lats"],
        "Pull": ["Back", "Biceps", "Upper Arms", "Traps", "Upper Back", "Lower Back"],
        "Legs": ["Quads", "Hamstrings", "Calves", "Glutes", "Lower Legs", "Upper Legs"]
    ]

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText, onTextChanged: filterExercises)
                    .padding(.top)

                // Filter Buttons (Body Part, Equipment, Splits)
                HStack(spacing: 16) {
                    // Body Part Button
                    Button(action: {
                        fetchBodyParts()
                        isBodyPartSheetPresented = true
                    }) {
                        Text(selectedBodyPart ?? "Body Part")
                            .font(.subheadline)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $isBodyPartSheetPresented) {
                        List {
                            Button("Body Part") {
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

                    // Equipment Button
                    Button(action: {
                        fetchEquipments()
                        isEquipmentSheetPresented = true
                    }) {
                        Text(selectedEquipment ?? "Equipment")
                            .font(.subheadline)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $isEquipmentSheetPresented) {
                        List {
                            Button("Equipment") {
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

                    // Splits Button
                    Button(action: {
                        isSplitSheetPresented = true
                    }) {
                        Text(selectedSplit ?? "Splits")
                            .font(.subheadline)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $isSplitSheetPresented) {
                        List {
                            Button("Splits") {
                                selectedSplit = nil
                                filterExercises(searchText)
                                isSplitSheetPresented = false
                            }
                            ForEach(splitMapping.keys.sorted(), id: \.self) { split in
                                Button(split) {
                                    selectedSplit = split
                                    filterExercises(searchText)
                                    isSplitSheetPresented = false
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Exercise List with selection and info icon
                List(filteredExercises) { exercise in
                    HStack {
                        ExerciseRowView(exercise: exercise)

                        Spacer()

                        // Info icon to navigate to ExerciseDetailView
                        Button(action: {
                            selectedExercise = exercise
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle()) // To avoid triggering list row tap
                        
                        // Show checkmark if the exercise is selected
                        if selectedExercises.contains(where: { $0.id == exercise.id }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .onTapGesture {
                        toggleSelection(for: exercise)
                    }
                }
            }
            .navigationBarTitle("Select Exercises")
            .navigationBarItems(
                leading: Button("Cancel") {
                    selectedExercises = [] // Clear selection on cancel
                },
                trailing: Button("Add") {
                    onAdd?() // Call the completion handler when "Add" is clicked
                }
                .disabled(selectedExercises.isEmpty) // Disable if no exercises are selected
            )
            .onAppear {
                loadExercisesFromFirebase()
            }
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
    }

    // Toggle selection of an exercise
    private func toggleSelection(for exercise: ExerciseModel) {
        if selectedExercises.contains(where: { $0.id == exercise.id }) {
            selectedExercises.removeAll { $0.id == exercise.id }
        } else {
            selectedExercises.append(exercise)
        }
    }

    // Fetch body parts from Firestore
    private func fetchBodyParts() {
        let db = Firestore.firestore()
        let docRef = db.collection("saved_exercises").document("exercisesview_list")
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching body parts: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, let exercisesArray = document.data()?["exercises"] as? [[String: Any]] else {
                print("No exercises found or data is not an array")
                return
            }

            var bodyPartsSet = Set<String>()
            for exerciseData in exercisesArray {
                if let bodyPart = exerciseData["bodyPart"] as? String {
                    let mappedBodyPart = bodyPartMapping[bodyPart] ?? bodyPart
                    bodyPartsSet.insert(mappedBodyPart)
                }
            }
            DispatchQueue.main.async {
                self.bodyParts = Array(bodyPartsSet).sorted()
            }
        }
    }

    // Fetch equipment from Firestore
    private func fetchEquipments() {
        let db = Firestore.firestore()
        let docRef = db.collection("saved_exercises").document("exercisesview_list")
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching equipment: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, let exercisesArray = document.data()?["exercises"] as? [[String: Any]] else {
                print("No exercises found or data is not an array")
                return
            }

            var equipmentsSet = Set<String>()
            for exerciseData in exercisesArray {
                if let equipment = exerciseData["equipment"] as? String {
                    let mappedEquipment = equipmentMapping[equipment] ?? equipment
                    equipmentsSet.insert(mappedEquipment)
                }
            }
            DispatchQueue.main.async {
                self.equipments = Array(equipmentsSet).sorted()
            }
        }
    }

    // Filter exercises based on search, body part, equipment, and splits
    private func filterExercises(_ text: String) {
        filteredExercises = exercises.filter { exercise in
            let mappedBodyPart = bodyPartMapping[exercise.bodyPart] ?? exercise.bodyPart
            let mappedEquipment = equipmentMapping[exercise.equipment] ?? exercise.equipment

            let searchText = text.lowercased()
            let nameMatches = exercise.name.lowercased().contains(searchText)
            let bodyPartMatches = mappedBodyPart.lowercased().contains(searchText)
            let equipmentMatches = mappedEquipment.lowercased().contains(searchText)
            let targetMatches = exercise.target.lowercased().contains(searchText)

            let secondaryMuscleMatches = exercise.secondaryMuscles?.contains(where: { muscle in
                muscle.lowercased().contains(searchText)
            }) ?? false

            let matchesBodyPartFilter = selectedBodyPart == nil || mappedBodyPart.lowercased() == selectedBodyPart?.lowercased()
            let matchesEquipmentFilter = selectedEquipment == nil || mappedEquipment.lowercased() == selectedEquipment?.lowercased()
            let matchesSplitFilter = selectedSplit == nil || splitMapping[selectedSplit!]?.contains(exercise.target) ?? false

            if searchText.isEmpty {
                return matchesBodyPartFilter && matchesEquipmentFilter && matchesSplitFilter
            }

            return (nameMatches || bodyPartMatches || equipmentMatches || targetMatches || secondaryMuscleMatches) &&
                matchesBodyPartFilter && matchesEquipmentFilter && matchesSplitFilter
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
                self.filteredExercises = self.exercises
            } catch {
                print("Failed to decode exercises: \(error.localizedDescription)")
            }
        }
    }
}



