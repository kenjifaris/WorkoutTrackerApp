//
//  ExerciseModel.swift
//  Workout Tracker
//
//  Created by Kenji on 8/19/24.
//

import Foundation

struct ExerciseModel: Identifiable, Codable {
    var id: String
    var name: String
    var target: String
    var bodyPart: String
    var equipment: String
    var category: String?
    var gifFileName: String?
    var secondaryMuscles: [String]?
    var instructions: [String]?

    // Custom initializer with default values for optional properties
    init(
        id: String,
        name: String,
        target: String,
        bodyPart: String,
        equipment: String,
        category: String? = nil,
        gifFileName: String? = nil,
        secondaryMuscles: [String]? = nil,
        instructions: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.target = target
        self.bodyPart = bodyPart
        self.equipment = equipment
        self.category = category
        self.gifFileName = gifFileName
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
    }

    // Initialize from Firestore dictionary (optional for Firestore fetch operations)
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let target = dictionary["target"] as? String,
              let bodyPart = dictionary["bodyPart"] as? String,
              let equipment = dictionary["equipment"] as? String else {
            return nil
        }

        self.id = id
        self.name = name
        self.target = target
        self.bodyPart = bodyPart
        self.equipment = equipment
        self.category = dictionary["category"] as? String
        self.gifFileName = dictionary["gifFileName"] as? String
        self.secondaryMuscles = dictionary["secondaryMuscles"] as? [String]
        self.instructions = dictionary["instructions"] as? [String]
    }

    // Convert to Firestore dictionary
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "target": target,
            "bodyPart": bodyPart,
            "equipment": equipment,
            "category": category ?? "",
            "gifFileName": gifFileName ?? "",
            "secondaryMuscles": secondaryMuscles ?? [],
            "instructions": instructions ?? []
        ]
    }
}
