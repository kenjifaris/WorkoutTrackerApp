//
//  ExerciseModel.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import Foundation

struct ExerciseModel: Identifiable, Equatable, Codable {
    let id: String
    var name: String // Changed to `var` to allow editing
    var target: String
    var bodyPart: String
    var equipment: String
    var gifUrl: String
    var category: String?
    var secondaryMuscles: [String]?
    var instructions: [String]?
    
    static func == (lhs: ExerciseModel, rhs: ExerciseModel) -> Bool {
        return lhs.id == rhs.id
    }
}








