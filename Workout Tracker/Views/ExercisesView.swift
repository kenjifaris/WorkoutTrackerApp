//
//  ExercisesView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct ExercisesView: View {
    @State private var exercises: [ExerciseModel] = []
    @State private var filteredExercises: [ExerciseModel] = []
    @State private var searchText: String = ""
    @State private var errorMessage: ErrorWrapper?
    @State private var isLoading = false
    @State private var offset: Int = 0 // Track the offset

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onTextChanged: filterExercises)
                
                List(filteredExercises) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.headline)
                            Text("Target: \(exercise.target)")
                                .font(.subheadline)
                            Text("Equipment: \(exercise.equipment)")
                                .font(.subheadline)

                            AsyncImage(url: URL(string: exercise.gifUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 150)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        .padding(.vertical)
                    }
                    .onAppear {
                        if exercise == filteredExercises.last { // Load more exercises when reaching the last item
                            loadExercises()
                        }
                    }
                }
                .navigationTitle("Exercises")
                .onAppear {
                    loadExercises() // Use the cached data if available
                }
                .alert(item: $errorMessage) { error in
                    Alert(
                        title: Text("Error"),
                        message: Text(error.message),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .overlay(isLoading ? ProgressView("Loading...") : nil)
        }
    }

    private func filterExercises(_ text: String) {
        if text.isEmpty {
            filteredExercises = exercises
        } else {
            filteredExercises = exercises.filter { $0.name.contains(text) }
        }
    }

    private func loadExercises() {
        guard !isLoading else { return } // Prevent multiple simultaneous loads
        isLoading = true
        ExerciseDBService().fetchExercises(offset: offset) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let newExercises):
                    self.exercises += newExercises
                    self.filteredExercises = self.exercises
                    if newExercises.count == 50 { // Continue loading if the max limit is reached
                        self.offset += 50 // Increase the offset for the next batch
                    }
                case .failure(let error):
                    self.errorMessage = ErrorWrapper(message: error.localizedDescription)
                }
            }
        }
    }
}

struct ErrorWrapper: Identifiable {  // Include this struct definition if not already included
    let id = UUID()
    let message: String
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
    }
}




































