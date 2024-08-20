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
            .onAppear(perform: loadExercises)
            .alert(item: $errorMessage) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func loadExercises() {
        ExerciseDBService().fetchExercises { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let exercises):
                    self.exercises = exercises
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
















