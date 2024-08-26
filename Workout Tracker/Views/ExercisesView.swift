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
    @State private var selectedCategory: String? = nil
    @State private var selectedExercises: [ExerciseModel] = []
    @State private var isLoading = false
    
    // State to manage sheet presentation
    @State private var isBodyPartSheetPresented = false
    @State private var isCategorySheetPresented = false
    @State private var bodyParts: [String] = []
    @State private var categories: [String] = []

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
                        fetchCategories()
                    }) {
                        Text(selectedCategory ?? "Any Category")
                            .font(.subheadline)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $isCategorySheetPresented) {
                        List {
                            Button("Any Category") {
                                selectedCategory = nil
                                filterExercises(searchText)
                                isCategorySheetPresented = false
                            }
                            ForEach(categories, id: \.self) { category in
                                Button(category) {
                                    selectedCategory = category
                                    filterExercises(searchText)
                                    isCategorySheetPresented = false
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
                        
                        // Add button
                        Button(action: {
                            addExercise(exercise)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
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
        }
    }

    private func fetchBodyParts() {
        guard let url = URL(string: "https://exercisedb.p.rapidapi.com/exercises/bodyPartList") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("3f9441b434msh1e9312855d9a072p1806fcjsn190e9e43c947", forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("exercisedb.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        isLoading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                    do {
                        let bodyPartsResponse = try JSONDecoder().decode([String].self, from: data)
                        self.bodyParts = bodyPartsResponse
                        self.isBodyPartSheetPresented = true
                    } catch {
                        print("Failed to decode body parts: \(error)")
                    }
                } else if let error = error {
                    print("Failed to fetch body parts: \(error)")
                }
            }
        }.resume()
    }

    private func fetchCategories() {
        guard let url = URL(string: "https://exercisedb.p.rapidapi.com/exercises/equipmentList") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("3f9441b434msh1e9312855d9a072p1806fcjsn190e9e43c947", forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("exercisedb.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        isLoading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                    do {
                        let categoriesResponse = try JSONDecoder().decode([String].self, from: data)
                        self.categories = categoriesResponse
                        self.isCategorySheetPresented = true
                    } catch {
                        print("Failed to decode categories: \(error)")
                    }
                } else if let error = error {
                    print("Failed to fetch categories: \(error)")
                }
            }
        }.resume()
    }

    private func filterExercises(_ text: String) {
        filteredExercises = exercises.filter { exercise in
            let matchesBodyPart = selectedBodyPart == nil || exercise.bodyPart == selectedBodyPart
            let matchesCategory = selectedCategory == nil || exercise.category == selectedCategory
            let matchesText = text.isEmpty || exercise.name.lowercased().contains(text.lowercased())

            return matchesBodyPart && matchesCategory && matchesText
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
        
        db.collection("public").document("user_exercises_1").getDocument { document, error in
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

















































