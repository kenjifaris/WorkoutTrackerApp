//
//  ExerciseDetailView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/20/24.
//

import SwiftUI
import Charts
import SDWebImageSwiftUI

struct ExerciseDetailView: View {
    var exercise: ExerciseModel
    var progressData: [ExerciseSet] // ExerciseSet data for the charts

    var body: some View {
        VStack {
            // TabView for switching between different sections (About, Charts, etc.)
            TabView {
                
                // About Tab (GIF + exercise details)
                ScrollView {
                    VStack(alignment: .leading) {
                        // Display the GIF (if available)
                        if let gifFileName = exercise.gifFileName,
                           let gifPath = Bundle.main.path(forResource: gifFileName, ofType: nil, inDirectory: "360") {
                            WebImage(url: URL(fileURLWithPath: gifPath))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 250)
                                .padding()
                        } else {
                            // Fallback if GIF is not found
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 250)
                                .padding()
                                .foregroundColor(.gray)
                        }

                        // Exercise Name as Title
                        Text(exercise.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)

                        // Body Part and Equipment info
                        HStack {
                            Text("Body Part:").fontWeight(.bold)
                            Text(exercise.bodyPart)
                            Spacer()
                            Text("Equipment:").fontWeight(.bold)
                            Text(exercise.equipment)
                        }
                        .padding(.vertical, 2)

                        // Target and Secondary Muscles
                        HStack(alignment: .top) {
                            Text("Target:").fontWeight(.bold)
                            Text(exercise.target)
                            Spacer()
                            Text("Secondary Muscles:").fontWeight(.bold)
                            VStack(alignment: .leading) {
                                ForEach(exercise.secondaryMuscles ?? [], id: \.self) { muscle in
                                    Text(muscle)
                                }
                            }
                        }
                        .padding(.vertical, 2)

                        Divider()

                        // Instructions Section
                        Text("Instructions").font(.headline).padding(.top, 10)
                        ForEach(exercise.instructions?.indices ?? 0..<0, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text("\(index + 1).").fontWeight(.bold).frame(width: 20, alignment: .leading)
                                Text(exercise.instructions?[index] ?? "").fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal, 16) // Padding around the content
                }
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }

                // Progress Charts Tab
                VStack {
                    Text("Exercise Progress")
                        .font(.headline)
                        .padding(.top)

                    // Display the progress chart
                    if progressData.isEmpty {
                        Text("No progress data available. Start tracking your sets!")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        // Ensure both `exercise` and `progressData` are passed
                        ExerciseProgressChartView(exercise: exercise, progressData: progressData)
                    }
                }
                .tabItem {
                    Label("Charts", systemImage: "chart.bar")
                }

                // Placeholder for other sections
                VStack {
                    Text("History Content")
                        .font(.headline)
                }
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

                VStack {
                    Text("PRs Content")
                        .font(.headline)
                }
                .tabItem {
                    Label("PRs", systemImage: "rosette")
                }
            }
            .padding(.bottom, 20) // Padding to avoid cutting off tab content
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(
            exercise: ExerciseModel(
                id: "0001",
                name: "Squat",
                target: "Legs",
                bodyPart: "Lower Legs",
                equipment: "Barbell",
                category: "Strength",
                gifFileName: "squat.gif",
                secondaryMuscles: ["Glutes", "Hamstrings"],
                instructions: ["Stand with feet shoulder-width apart.", "Lower your body down by bending knees.", "Keep your back straight.", "Push up back to standing position."]
            ),
            progressData: [
                ExerciseSet(setNumber: 1, weight: 100, reps: 10),
                ExerciseSet(setNumber: 2, weight: 110, reps: 8),
                ExerciseSet(setNumber: 3, weight: 120, reps: 6)
            ]
        )
    }
}
