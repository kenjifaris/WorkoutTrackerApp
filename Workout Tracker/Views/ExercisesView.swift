//
//  ExercisesView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct ExercisesView: View {
    @State private var exercises: [ExerciseModel] = []
    @State private var errorMessage: ErrorWrapper?
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            List(exercises) { exercise in
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
            .navigationTitle("Exercises")
            .onAppear {
                loadExercises()
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

    private func loadExercises(offset: Int = 0) {
        isLoading = true
        ExerciseDBService().fetchExercises(offset: offset) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let exercises):
                    self.exercises += exercises
                    if exercises.count == 50 { // Continue loading if the max limit is reached
                        loadExercises(offset: offset + 50)
                    }
                case .failure(let error):
                    self.errorMessage = ErrorWrapper(message: error.localizedDescription)
                }
            }
        }
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}



















