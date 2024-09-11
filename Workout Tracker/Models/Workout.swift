//
//  Workout.swift
//  Workout Tracker
//
//  Created by Kenji on 9/11/24.
//

import Foundation

struct Workout: Identifiable, Codable {
    let id: String
    let workoutName: String
    let workoutDuration: TimeInterval
    let exerciseSets: [String: [ExerciseSet]] // Map of exerciseId to array of sets

    // Initialize from Firestore dictionary manually (for non-Codable workflow)
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let workoutName = dictionary["workoutName"] as? String,
              let workoutDuration = dictionary["workoutDuration"] as? TimeInterval,
              let exerciseSetsDict = dictionary["exerciseSets"] as? [String: [[String: Any]]] else {
            return nil
        }
        
        self.id = id
        self.workoutName = workoutName
        self.workoutDuration = workoutDuration
        
        // Convert exerciseSets from Firestore format to ExerciseSet
        var sets: [String: [ExerciseSet]] = [:]
        for (key, setDictArray) in exerciseSetsDict {
            var exerciseSetArray: [ExerciseSet] = []
            for setDict in setDictArray {
                if let exerciseSet = ExerciseSet(from: setDict) {
                    exerciseSetArray.append(exerciseSet)
                }
            }
            sets[key] = exerciseSetArray
        }
        self.exerciseSets = sets
    }

    // Custom initializer
    init(id: String, workoutName: String, workoutDuration: TimeInterval, exerciseSets: [String: [ExerciseSet]]) {
        self.id = id
        self.workoutName = workoutName
        self.workoutDuration = workoutDuration
        self.exerciseSets = exerciseSets
    }

    // Convert to Firestore dictionary
    func toDictionary() -> [String: Any] {
        var exerciseSetsDict: [String: [[String: Any]]] = [:]
        for (key, sets) in exerciseSets {
            exerciseSetsDict[key] = sets.map { $0.toDictionary() }
        }
        
        return [
            "id": id,
            "workoutName": workoutName,
            "workoutDuration": workoutDuration,
            "exerciseSets": exerciseSetsDict
        ]
    }
}
