//
//  ExerciseProgressChartView.swift
//  Workout Tracker
//
//  Created by Kenji  on 9/11/24.
//

import SwiftUI
import Charts

struct ExerciseProgressChartView: View {
    var exercise: ExerciseModel
    var progressData: [ExerciseSet]

    var body: some View {
        Chart(progressData) {
            LineMark(
                x: .value("Set", $0.setNumber),
                y: .value("Weight", $0.weight ?? 0)
            )
            PointMark(
                x: .value("Set", $0.setNumber),
                y: .value("Weight", $0.weight ?? 0)
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


