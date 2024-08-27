//
//  FirestoreService.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/27/24.
//

import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    
    private init() {}

    func bulkUpdateExerciseNames() {
        let db = Firestore.firestore()
        let docRef = db.collection("public").document("user_exercises_2")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data(), let exercisesArray = data["exercises"] as? [[String: Any]] {
                    var updatedExercises: [[String: Any]] = []

                    // Loop through each exercise
                    for var exercise in exercisesArray {
                        // Capitalize the 'name' field
                        if let name = exercise["name"] as? String {
                            let newName = name.capitalized
                            exercise["name"] = newName
                        }

                        // Capitalize the 'bodyPart' field
                        if let bodyPart = exercise["bodyPart"] as? String {
                            let newBodyPart = bodyPart.capitalized
                            exercise["bodyPart"] = newBodyPart
                        }

                        // Capitalize the 'equipment' field
                        if let equipment = exercise["equipment"] as? String {
                            let newEquipment = equipment.capitalized
                            exercise["equipment"] = newEquipment
                        }

                        // Capitalize the 'target' field
                        if let target = exercise["target"] as? String {
                            let newTarget = target.capitalized
                            exercise["target"] = newTarget
                        }

                        // Capitalize each entry in 'secondaryMuscles' array
                        if var secondaryMuscles = exercise["secondaryMuscles"] as? [String] {
                            secondaryMuscles = secondaryMuscles.map { $0.capitalized }
                            exercise["secondaryMuscles"] = secondaryMuscles
                        }

                        updatedExercises.append(exercise)
                    }

                    // Update the document with modified fields
                    docRef.updateData(["exercises": updatedExercises]) { error in
                        if let error = error {
                            print("Error updating exercises: \(error)")
                        } else {
                            print("Successfully updated exercise names and fields")
                        }
                    }
                } else {
                    print("No exercises found or error: \(error?.localizedDescription ?? "Unknown error")")
                }
            } else {
                print("Document does not exist or failed to fetch: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}





