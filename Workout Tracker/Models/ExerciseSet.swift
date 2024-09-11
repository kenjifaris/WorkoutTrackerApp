//
//  ExerciseSet.swift
//  Workout Tracker
//
//  Created by Kenji on 9/9/24.
//

import Foundation

struct ExerciseSet: Identifiable, Codable {
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

    // Convert to Firestore dictionary
    func toDictionary() -> [String: Any] {
        return [
            "setNumber": setNumber,
            "weight": weight ?? 0,
            "reps": reps ?? 0
        ]
    }

    // Initialize ExerciseSet from Firestore dictionary
    init?(from dictionary: [String: Any]) {
        guard let setNumber = dictionary["setNumber"] as? Int else {
            return nil
        }
        
        let weight = dictionary["weight"] as? Double
        let reps = dictionary["reps"] as? Int
        
        self.init(setNumber: setNumber, weight: weight, reps: reps)
    }
}
