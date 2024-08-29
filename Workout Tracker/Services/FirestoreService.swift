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
    
    // Helper function to capitalize the first letter of each word in a string
    private func capitalizeWords(in text: String) -> String {
        return text.capitalized
    }
    
    // Helper function to capitalize all words in an array of strings
    private func capitalizeWords(in array: [String]) -> [String] {
        return array.map { $0.capitalized }
    }
    
    // Method to update and capitalize exercise fields specifically in 'saved_exercises/exercisesview_list'
    func updateAndCapitalizeExerciseFields() {
        let db = Firestore.firestore()
        let documentRef = db.collection("saved_exercises").document("exercisesview_list")

        documentRef.getDocument { [weak self] document, error in
            guard let self = self else { return }  // Ensure self exists
            guard let document = document, document.exists, var exerciseDataArray = document.data()?["exercises"] as? [[String: Any]], error == nil else {
                print("Error fetching exercises: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            for i in 0..<exerciseDataArray.count {
                var exerciseData = exerciseDataArray[i]

                // Capitalize the relevant fields
                if let name = exerciseData["name"] as? String {
                    exerciseData["name"] = self.capitalizeWords(in: name)
                }
                if let target = exerciseData["target"] as? String {
                    exerciseData["target"] = self.capitalizeWords(in: target)
                }
                if let bodyPart = exerciseData["bodyPart"] as? String {
                    exerciseData["bodyPart"] = self.capitalizeWords(in: bodyPart)
                }
                if let equipment = exerciseData["equipment"] as? String {
                    exerciseData["equipment"] = self.capitalizeWords(in: equipment)
                }
                if let secondaryMuscles = exerciseData["secondaryMuscles"] as? [String] {
                    exerciseData["secondaryMuscles"] = self.capitalizeWords(in: secondaryMuscles)
                }

                // Update the modified exercise data back into the array
                exerciseDataArray[i] = exerciseData
            }

            // Update the Firestore document with the capitalized data
            documentRef.updateData(["exercises": exerciseDataArray]) { error in
                if let error = error {
                    print("Failed to update exercises with capitalized fields: \(error.localizedDescription)")
                } else {
                    print("Successfully updated exercises with capitalized fields in 'saved_exercises/exercisesview_list'")
                }
            }
        }
    }

    // Function to duplicate the 'exercisesview_list' document
    func duplicateExercisesViewList(newDocumentID: String) {
        let db = Firestore.firestore()
        let originalDocRef = db.collection("saved_exercises").document("exercisesview_list")
        let newDocRef = db.collection("saved_exercises").document(newDocumentID)

        originalDocRef.getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("Error fetching original document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let data = document.data() {
                // Set the data into the new document
                newDocRef.setData(data) { error in
                    if let error = error {
                        print("Error duplicating document: \(error.localizedDescription)")
                    } else {
                        print("Document successfully duplicated with ID: \(newDocumentID)")
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
            "name": name.capitalized,
            "target": target.capitalized,
            "bodyPart": bodyPart.capitalized,
            "equipment": equipment.capitalized,
            "category": category ?? "",
            "gifFileName": gifFileName ?? "",
            "secondaryMuscles": secondaryMuscles?.map { $0.capitalized } ?? [],
            "instructions": instructions ?? []
        ]
    }
}

















