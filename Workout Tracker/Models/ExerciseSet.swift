//  ExerciseSet.swift

import Foundation

struct ExerciseSet: Identifiable, Codable {
    var id = UUID()
    var setNumber: Int
    var weight: Double?
    var reps: Int?

    var weightString: String = ""
    var repsString: String = ""

    init(setNumber: Int, weight: Double? = nil, reps: Int? = nil) {
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.weightString = weight != nil ? "\(weight!)" : ""
        self.repsString = reps != nil ? "\(reps!)" : ""
    }

    // Convert weight and reps strings to their numeric equivalents
    mutating func convertStringsToValues() {
        weight = Double(weightString) ?? 0
        reps = Int(repsString) ?? 0
    }

    func toDictionary() -> [String: Any] {
        return [
            "setNumber": setNumber,
            "weight": weight ?? 0,
            "reps": reps ?? 0
        ]
    }

    init?(from dictionary: [String: Any]) {
        guard let setNumber = dictionary["setNumber"] as? Int else { return nil }
        let weight = dictionary["weight"] as? Double
        let reps = dictionary["reps"] as? Int
        self.init(setNumber: setNumber, weight: weight, reps: reps)
    }
}
