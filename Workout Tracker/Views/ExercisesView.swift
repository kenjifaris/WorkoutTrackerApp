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

    // State to manage sheet presentation
    @State private var isBodyPartSheetPresented = false
    @State private var isEquipmentSheetPresented = false
    @State private var bodyParts: [String] = []
    @State private var equipments: [String] = []

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
                        .onAppear {
                            fetchBodyParts()
                        }
                    }

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
                        .onAppear {
                            fetchEquipments()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Exercise List
                List(filteredExercises) { exercise in
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
                            Text(exercise.name)
                                .font(.headline)

                            Text(exercise.target)
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Text(exercise.equipment)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Button(action: {
                            toggleSelection(for: exercise)
                        }) {
                            Image(systemName: selectedExercises.contains(exercise) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedExercises.contains(exercise) ? .blue : .gray)
                                .font(.title2)
                        }
                    }
                    .padding(.vertical, 5)
                    .onTapGesture {
                        toggleSelection(for: exercise)
                    }
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
            .onAppear(perform: {
                loadExercisesFromFirebase()
            }) // Load from Firestore
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

            print("Exercises Array: \(exercisesArray)")

            var bodyPartsSet = Set<String>()
            for exerciseData in exercisesArray {
                if let bodyPart = exerciseData["bodyPart"] as? String {
                    print("Found body part: \(bodyPart)")  // Debug log
                    bodyPartsSet.insert(bodyPart)
                }
            }
            DispatchQueue.main.async {
                self.bodyParts = Array(bodyPartsSet).sorted()
                print("Body Parts Set: \(self.bodyParts)")  // Debug log
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

            print("Exercises Array: \(exercisesArray)")

            var equipmentsSet = Set<String>()
            for exerciseData in exercisesArray {
                if let equipment = exerciseData["equipment"] as? String {
                    print("Found equipment: \(equipment)")  // Debug log
                    equipmentsSet.insert(equipment)
                }
            }
            DispatchQueue.main.async {
                self.equipments = Array(equipmentsSet).sorted()
                print("Equipments Set: \(self.equipments)")  // Debug log
            }
        }
    }

    // Filter exercises
    private func filterExercises(_ text: String) {
        filteredExercises = exercises.filter { exercise in
            let matchesBodyPart = selectedBodyPart == nil || exercise.bodyPart == selectedBodyPart
            let matchesEquipment = selectedEquipment == nil || exercise.equipment == selectedEquipment
            let matchesText = text.isEmpty || exercise.name.lowercased().contains(text.lowercased())

            return matchesBodyPart && matchesEquipment && matchesText
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

    private func toggleSelection(for exercise: ExerciseModel) {
        if let index = selectedExercises.firstIndex(of: exercise) {
            selectedExercises.remove(at: index)
        } else {
            selectedExercises.append(exercise)
        }
    }

    private func finalizeWorkout() {
        // Navigate to a summary page or perform the desired action
        print("Finalized workout with \(selectedExercises.count) exercises.")
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
    }
}







































































