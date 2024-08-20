//
//  ExerciseModel.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import Foundation

struct ExerciseModel: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let target: String
    let bodyPart: String
    let equipment: String
    let gifUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case target
        case bodyPart
        case equipment
        case gifUrl = "gifUrl"
    }

    // Equatable conformance
    static func ==(lhs: ExerciseModel, rhs: ExerciseModel) -> Bool {
        return lhs.id == rhs.id
    }
}




