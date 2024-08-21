//
//  ExerciseDetailView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/20/24.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: ExerciseModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(exercise.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Target: \(exercise.target)")
                    .font(.title2)

                Text("Body Part: \(exercise.bodyPart)")
                    .font(.title3)

                Text("Equipment: \(exercise.equipment)")
                    .font(.title3)

                AsyncImage(url: URL(string: exercise.gifUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                } placeholder: {
                    ProgressView()
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(exercise.name)
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(exercise: ExerciseModel(
            id: "1",
            name: "Push Up",
            target: "Chest",
            bodyPart: "Chest",
            equipment: "Body weight",
            gifUrl: "https://someurl.com/pushup.gif",
            category: "Strength",
            secondaryMuscles: ["Triceps", "Shoulders"],
            instructions: [
                "Start in a high plank position with your hands placed slightly wider than shoulder-width apart.",
                "Lower your body until your chest nearly touches the floor.",
                "Push back up to the starting position.",
                "Repeat for the desired number of repetitions."
            ]
        ))
    }
}



