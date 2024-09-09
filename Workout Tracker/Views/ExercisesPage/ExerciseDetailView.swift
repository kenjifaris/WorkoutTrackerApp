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
                // About tab (GIF + exercise details + instructions)
                ScrollView {
                    VStack(alignment: .leading) {
                        // Display the GIF with a fixed size
                        if let gifFileName = exercise.gifFileName,
                           let gifPath = Bundle.main.path(forResource: gifFileName, ofType: nil, inDirectory: "360") {
                            WebImage(url: URL(fileURLWithPath: gifPath))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 250) // Fixed height for the GIF
                                .padding()
                        } else {
                            // Fallback in case GIF is not found
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 250) // Fixed height for placeholder
                                .padding()
                                .foregroundColor(.gray)
                        }

                        // Exercise Name as a Title
                        Text(exercise.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)

                        // Body Part and Equipment in a horizontal layout
                        HStack {
                            Text("Body Part:")
                                .fontWeight(.bold)
                            Text(exercise.bodyPart)
                            Spacer()
                            Text("Equipment:")
                                .fontWeight(.bold)
                            Text(exercise.equipment)
                        }
                        .padding(.vertical, 2)

                        // Target and Secondary Muscles in a horizontal layout
                        HStack(alignment: .top) {
                            Text("Target:")
                                .fontWeight(.bold)
                            Text(exercise.target)
                            Spacer()
                            Text("Secondary Muscles:")
                                .fontWeight(.bold)
                            VStack(alignment: .leading) {
                                ForEach(exercise.secondaryMuscles ?? [], id: \.self) { muscle in
                                    Text(muscle)
                                }
                            }
                        }
                        .padding(.vertical, 2)

                        Divider() // Divider to separate metadata and instructions

                        // Instructions section
                        Text("Instructions")
                            .font(.headline)
                            .padding(.top, 10)

                        // Numbered instructions with alignment
                        ForEach(exercise.instructions?.indices ?? 0..<0, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .fontWeight(.bold)
                                    .frame(width: 20, alignment: .leading)
                                    .alignmentGuide(.top) { _ in 0 }

                                Text(exercise.instructions?[index] ?? "")
                                    .fixedSize(horizontal: false, vertical: true)
                                    .alignmentGuide(.top) { _ in 0 }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal, 16) // Padding around the entire content
                }
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }

                // History tab
                VStack {
                    Text("History Content")
                        .font(.headline)
                }
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

                // Charts tab
                VStack {
                    Text("Charts Content")
                        .font(.headline)
                }
                .tabItem {
                    Label("Charts", systemImage: "chart.bar")
                }

                // PRs tab (Personal Records)
                VStack {
                    Text("PRs Content")
                        .font(.headline)
                }
                .tabItem {
                    Label("PRs", systemImage: "rosette")
                }
            }
            .padding(.bottom, 20) // Avoid cutting off tab content
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
















