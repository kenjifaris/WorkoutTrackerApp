//
//  ExerciseProgressChartView.swift
//  Workout Tracker
//
//  Created by Kenji  on 9/11/24.
//

import SwiftUI
import Charts

struct ExerciseProgressChartView: View {
    var progressData: [ExerciseSet]  // No need for `exercise: ExerciseModel` anymore

    var body: some View {
        VStack {
            Text("Progress Data")  // Title for context
                .font(.headline)
                .padding()

            if progressData.isEmpty {
                Text("No progress data available. Start tracking your sets!")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart(progressData) {
                    LineMark(
                        x: .value("Set", $0.setNumber),
                        y: .value("Weight", $0.weight ?? 0) // Default to 0 if weight is nil
                    )
                    PointMark(
                        x: .value("Set", $0.setNumber),
                        y: .value("Weight", $0.weight ?? 0) // Default to 0 if weight is nil
                    )
                    .foregroundStyle(.blue)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: 1))
                }
                .padding()
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
