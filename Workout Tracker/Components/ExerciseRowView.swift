//
//  ExerciseRowView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct ExerciseRowView: View {
    let exercise: ExerciseModel

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: exercise.gifUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } placeholder: {
                ProgressView()
                    .frame(width: 50, height: 50)
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
        ExerciseRowView(exercise: ExerciseModel(id: "0001", name: "Push Up", target: "Chest", bodyPart: "Chest", equipment: "Body weight", gifUrl: "https://example.com/pushup.gif"))
    }
}

