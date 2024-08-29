//
//  ExerciseRowView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ExerciseRowView: View {
    let exercise: ExerciseModel

    var body: some View {
        HStack {
            if let gifFileName = exercise.gifFileName {
                // Use the folder reference path here
                let gifPath = Bundle.main.path(forResource: "360/\(gifFileName)", ofType: nil)
                
                if let gifPath = gifPath {
                    WebImage(url: URL(fileURLWithPath: gifPath))
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
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }

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
            category: "Strength",
            gifFileName: "0001.gif",
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























