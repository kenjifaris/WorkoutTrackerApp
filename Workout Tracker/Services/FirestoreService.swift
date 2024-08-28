//
//  FirestoreService.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/27/24.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    
    private init() {}

    // Method to upload JSON data to Firestore (already done but included for reference)
    func uploadJSONDataToFirestore() {
        // This method would include the logic to upload JSON data to Firestore if needed.
    }
    
    // Method to bulk update exercise names (existing)
    func bulkUpdateExerciseNames() {
        // Existing bulk update method logic if required.
    }
    
    // Method to match GIFs to exercises
    func matchGifsToExercises() {
        let db = Firestore.firestore()
        let exercisesCollection = db.collection("exercises")

        exercisesCollection.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching exercises: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            for document in documents {
                var exerciseData = document.data()
                if let exerciseId = exerciseData["id"] as? String {
                    let gifFileName = "\(exerciseId).gif"
                    
                    if Bundle.main.path(forResource: gifFileName, ofType: nil, inDirectory: "360") != nil {
                        exerciseData["gifFileName"] = gifFileName
                    } else {
                        print("GIF not found for exercise ID \(exerciseId)")
                    }

                    exercisesCollection.document(exerciseId).updateData(exerciseData) { error in
                        if let error = error {
                            print("Failed to update exercise \(exerciseId) with GIF: \(error.localizedDescription)")
                        } else {
                            print("Successfully updated exercise \(exerciseId) with GIF \(gifFileName)")
                        }
                    }
                }
            }
        }
    }
}

// Helper to convert the ExerciseModel to dictionary
extension ExerciseModel {
    var dictionary: [String: Any] {
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













