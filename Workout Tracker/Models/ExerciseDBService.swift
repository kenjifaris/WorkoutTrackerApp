//
//  ExerciseDBService.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import Foundation

class ExerciseDBService {
    private let baseURL = "https://exercisedb.p.rapidapi.com/exercises"
    private let apiKey = "3f9441b434msh1e9312855d9a072p1806fcjsn190e9e43c947"  // Replace with your actual API key
    private let limit = 50  // Number of exercises per page

    // Function to fetch all exercises
    func fetchAllExercises(completion: @escaping (Result<[ExerciseModel], Error>) -> Void) {
        fetchExercises(offset: 0, accumulatedExercises: [], completion: completion)
    }

    // Recursive function to handle pagination and fetch all exercises
    private func fetchExercises(offset: Int, accumulatedExercises: [ExerciseModel], completion: @escaping (Result<[ExerciseModel], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?offset=\(offset)&limit=\(limit)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
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
                
                // Accumulate exercises
                let allExercises = accumulatedExercises + exercises
                
                // If the API returns fewer items than the limit, we've reached the last page
                if exercises.count < self.limit {
                    completion(.success(allExercises))
                } else {
                    // Otherwise, fetch the next page
                    self.fetchExercises(offset: offset + self.limit, accumulatedExercises: allExercises, completion: completion)
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}





















