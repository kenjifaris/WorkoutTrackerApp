//
//  ExerciseProgressChartView.swift
//  Workout Tracker
//
//  Created by Kenji  on 9/11/24.
//

import SwiftUI
import Charts

struct ExerciseProgressChartView: View {
    var progressData: [ExerciseSet]  // Holds the exercise progress sets

    var body: some View {
        VStack {
            Text("Progress Data")
                .font(.headline)
                .padding()

            if progressData.isEmpty {
                // **Highlight**: Show no progress data if the array is empty
                Text("No progress data available. Start tracking your sets!")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // **Highlight**: Chart showing the weight lifted over time (sets)
                Chart(progressData) { set in
                    LineMark(
                        x: .value("Set", set.setNumber),     // Set number (x-axis)
                        y: .value("Weight", set.weight ?? 0) // Weight lifted (y-axis)
                    )
                    .symbol(Circle())
                    .interpolationMethod(.catmullRom)  // Smoother lines for the chart
                    
                    PointMark(
                        x: .value("Set", set.setNumber),
                        y: .value("Weight", set.weight ?? 0)
                    )
                    .foregroundStyle(.blue) // Style for the point marks
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: 1)) // X-axis for each set
                }
                .padding()
                .onAppear {
                    print("Rendering chart for \(progressData.count) sets.")
                }
            }
        }
    }
}

struct ExerciseProgressChartView_Previews: PreviewProvider {
    static var previews: some View {
        // Injecting mock data for testing
        ExerciseProgressChartView(
            progressData: [
                ExerciseSet(setNumber: 1, weight: 100, reps: 10),
                ExerciseSet(setNumber: 2, weight: 110, reps: 8),
                ExerciseSet(setNumber: 3, weight: 120, reps: 6),
                ExerciseSet(setNumber: 4, weight: 130, reps: 5)
            ]
        )
    }
}
