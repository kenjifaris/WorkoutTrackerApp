//
//  ExerciseModel.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import Foundation

struct ExerciseModel: Identifiable, Equatable, Codable {
    let id: String
    var name: String
    var target: String
    var bodyPart: String
    var equipment: String
    var category: String?
    var gifFileName: String?
    var secondaryMuscles: [String]?
    var instructions: [String]?

    static func == (lhs: ExerciseModel, rhs: ExerciseModel) -> Bool {
        return lhs.id == rhs.id
    }
}











