//
//  ExerciseRowView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI
import SDWebImageSwiftUI  // Import SDWebImageSwiftUI

struct ExerciseRowView: View {
    let exercise: ExerciseModel

    var body: some View {
        HStack {
            WebImage(url: URL(string: exercise.gifUrl))
                .onSuccess { image, data, cacheType in
                    print("Successfully loaded GIF: \(exercise.gifUrl)")
                }
                .onFailure { error in
                    print("Failed to load GIF: \(exercise.gifUrl), Error: \(error.localizedDescription)")
                }
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
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
        }
        .padding(.vertical, 8)
    }
}

struct ExerciseRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseRowView(exercise: ExerciseModel(
            id: "0001",
            name: "Push Up",
            target: "Chest",
            bodyPart: "Chest",
            equipment: "Body weight",
            gifUrl: "https://example.com/pushup.gif",
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









