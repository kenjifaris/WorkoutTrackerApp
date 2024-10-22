//
//  ExercisesView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI

struct ExercisesView: View {
    @State private var exercises: [ExerciseModel] = []
    @State private var filteredExercises: [ExerciseModel] = []
    @State private var searchText: String = ""
    @State private var selectedBodyPart: String? = nil
    @State private var selectedEquipment: String? = nil
    @State private var selectedSplit: String? = nil
    @State private var isLoading = false

    // State to manage sheet presentation
    @State private var isBodyPartSheetPresented = false
    @State private var isEquipmentSheetPresented = false
    @State private var isSplitSheetPresented = false
    @State private var bodyParts: [String] = []
    @State private var equipments: [String] = []

    // State for selected exercise to display in sheet
    @State private var selectedExercise: ExerciseModel? = nil
    @State private var progressData: [ExerciseSet] = [] // Holds fetched progress data

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

    // Define the mapping for workout splits
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

                // Exercise List
                List(filteredExercises) { exercise in
                    Button(action: {
                        // Fetch progress data for the selected exercise
                        fetchProgressData(for: exercise.id) { progress in
                            self.progressData = progress
                            self.selectedExercise = exercise
                        }
                    }) {
                        ExerciseRowView(exercise: exercise)
                    }
                    .buttonStyle(PlainButtonStyle()) // To prevent default button styling
                }
                .sheet(item: $selectedExercise) { exercise in
                    ExerciseDetailView(
                        exercise: exercise,
                        loadProgressData: { selectedExercise, completion in
                            fetchProgressData(for: selectedExercise.id, completion: completion)
                        }
                    )
                }
                .navigationTitle("Exercises")
                .onAppear {
                    loadExercisesFromFirebase()
                }
            }
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
                    // Apply the body part mapping
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
                    // Apply the equipment mapping
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

            // Convert fields to lowercase for case-insensitive search
            let searchText = text.lowercased()

            let nameMatches = exercise.name.lowercased().contains(searchText)
            let bodyPartMatches = mappedBodyPart.lowercased().contains(searchText)
            let equipmentMatches = mappedEquipment.lowercased().contains(searchText)
            let targetMatches = exercise.target.lowercased().contains(searchText)

            // Check if any of the secondary muscles match the search text
            let secondaryMuscleMatches = exercise.secondaryMuscles?.contains(where: { muscle in
                muscle.lowercased().contains(searchText)
            }) ?? false

            // Ensure the exercise matches body part, equipment, and split filters (if selected)
            let matchesBodyPartFilter = selectedBodyPart == nil || mappedBodyPart.lowercased() == selectedBodyPart?.lowercased()
            let matchesEquipmentFilter = selectedEquipment == nil || mappedEquipment.lowercased() == selectedEquipment?.lowercased()

            // Split filter: Check if the target matches any of the selected split's muscles
            let matchesSplitFilter = selectedSplit == nil || splitMapping[selectedSplit!]?.contains(exercise.target) ?? false

            // When the search bar is empty, only apply the body part, equipment, and split filters
            if searchText.isEmpty {
                return matchesBodyPartFilter && matchesEquipmentFilter && matchesSplitFilter
            }

            // Return true if the search term matches any field, and the body part/equipment/split filters are respected
            return (nameMatches || bodyPartMatches || equipmentMatches || targetMatches || secondaryMuscleMatches) && matchesBodyPartFilter && matchesEquipmentFilter && matchesSplitFilter
        }
    }

    // Load exercises from Firestore
    private func loadExercisesFromFirebase() {
        let db = Firestore.firestore()
        let docRef = db.collection("saved_exercises").document("exercisesview_list")
        
        docRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("Document does not exist: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let data = document.data(), let exercisesArray = data["exercises"] as? [[String: Any]] {
                    self.exercises = try exercisesArray.compactMap { dict -> ExerciseModel? in
                        return try? JSONDecoder().decode(ExerciseModel.self, from: JSONSerialization.data(withJSONObject: dict))
                    }
                    self.filteredExercises = self.exercises
                }
            } catch {
                print("Failed to decode exercises: \(error)")
            }
        }
    }

    // Fetch progress data for the selected exercise
    private func fetchProgressData(for exerciseID: String, completion: @escaping ([ExerciseSet]) -> Void) {
        let db = Firestore.firestore()
        db.collection("workout_progress")
            .whereField("exerciseID", isEqualTo: exerciseID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching progress data: \(error.localizedDescription)")
                    completion([]) // Return empty if error occurs
                    return
                }

                // Decode the ExerciseSet from each Firestore document
                let progressData = snapshot?.documents.compactMap { document -> ExerciseSet? in
                    return try? document.data(as: ExerciseSet.self)
                } ?? []
                completion(progressData)
            }
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
    }
}
