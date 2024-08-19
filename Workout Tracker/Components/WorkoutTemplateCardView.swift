//
//  WorkoutTemplateCardView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct WorkoutTemplateCardView: View {
    let template: WorkoutTemplate
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.1))
            .frame(height: 100)
            .overlay(
                VStack(alignment: .leading) {
                    HStack {
                        Text(template.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            // More options action
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                        }
                    }
                    Text(template.exercises)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
            )
    }
}

struct WorkoutTemplateCardView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTemplateCardView(template: WorkoutTemplate(name: "Legs", exercises: "Squat (Barbell), Leg Extension (Machine)"))
    }
}

