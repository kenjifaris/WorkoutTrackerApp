//
//  ExerciseSet.swift
//  Workout Tracker
//
//  Created by Kenji  on 9/9/24.
//

import Foundation

struct ExerciseSet: Identifiable {
    var id = UUID()
    var setNumber: Int
    var weight: Double?
    var reps: Int?

    // Temporary strings to bind with TextFields (can be converted to weight/reps on save)
    var weightString: String = ""
    var repsString: String = ""

    // Add initializer to map weight and reps strings to Double and Int
    init(setNumber: Int, weight: Double? = nil, reps: Int? = nil) {
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.weightString = weight != nil ? "\(weight!)" : ""
        self.repsString = reps != nil ? "\(reps!)" : ""
    }
}


