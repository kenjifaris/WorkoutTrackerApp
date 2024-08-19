//
//  ExercisesView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct ExercisesView: View {
    @State private var searchText = ""
    
    // Organized exercises by their first letter
    private var organizedExercises: [String: [Exercise]] {
        Dictionary(grouping: SampleExercises.exercises) { exercise in
            String(exercise.name.prefix(1)).uppercased()
        }
    }
    
    private var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return SampleExercises.exercises
        } else {
            return SampleExercises.exercises.filter { exercise in
                exercise.name.lowercased().contains(searchText.lowercased()) ||
                exercise.category.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // A-Z Sections
                ForEach(organizedExercises.keys.sorted(), id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(organizedExercises[key]!) { exercise in
                            ExerciseRowView(exercise: exercise)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Exercises")
            .searchable(text: $searchText, prompt: "Search Exercises")
        }
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            Image(exercise.imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                Text(exercise.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
    }
}




