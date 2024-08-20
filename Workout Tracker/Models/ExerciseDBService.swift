//
//  ExerciseDBService.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import Foundation

class ExerciseDBService {
    let baseURL = "https://exercisedb.p.rapidapi.com/exercises"

    func fetchExercises(completion: @escaping (Result<[ExerciseModel], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("3f9441b434msh1e9312855d9a072p1806fcjsn190e9e43c947", forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("exercisedb.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let exercises = try JSONDecoder().decode([ExerciseModel].self, from: data)
                completion(.success(exercises))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}








