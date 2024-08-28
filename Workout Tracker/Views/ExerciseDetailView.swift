//
//  ExerciseDetailView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/20/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ExerciseDetailView: View {
    var exercise: ExerciseModel

    var body: some View {
        VStack {
            // TabView to switch between About, History, Charts, PRs
            TabView {
                VStack {
                    // Display the GIF using SDWebImageSwiftUI with local file
                    if let gifFileName = exercise.gifFileName,
                       let gifPath = Bundle.main.path(forResource: gifFileName, ofType: nil),
                       let gifUrl = URL(string: gifPath) {
                        WebImage(url: gifUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                    
                    // Display the instructions
                    Text("Instructions")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(exercise.instructions ?? [], id: \.self) { instruction in
                        Text(instruction)
                            .padding(.vertical, 2)
                    }
                }
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                
                // Other tabs (History, Charts, PRs)
                Text("History Content")
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                
                Text("Charts Content")
                    .tabItem {
                        Label("Charts", systemImage: "chart.bar")
                    }
                
                Text("PRs Content")
                    .tabItem {
                        Label("PRs", systemImage: "rosette")
                    }
            }
            .padding()
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}







