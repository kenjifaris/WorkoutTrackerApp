//
//  ExerciseModel.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import Foundation

struct ExerciseModel: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let target: String
    let bodyPart: String
    let equipment: String
    let gifUrl: String
    let category: String?
    let secondaryMuscles: [String]?
    let instructions: [String]?
    
    // Conformance to Equatable
    static func == (lhs: ExerciseModel, rhs: ExerciseModel) -> Bool {
        return lhs.id == rhs.id
    }
}







