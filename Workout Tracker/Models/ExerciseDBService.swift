//
//  ExerciseDBService.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import Foundation

class ExerciseDBService {
    private let baseURL = "https://exercisedb.p.rapidapi.com/exercises"
    private let cacheKey = "cachedExercises"

    // Fetch Exercises with Caching
    func fetchExercises(offset: Int = 0, completion: @escaping (Result<[ExerciseModel], Error>) -> Void) {
        // Check if cached data exists
        if offset == 0, let cachedData = UserDefaults.standard.data(forKey: cacheKey) {
            do {
                let cachedExercises = try JSONDecoder().decode([ExerciseModel].self, from: cachedData)
                completion(.success(cachedExercises))
                return
            } catch {
                // Handle error if cache data is corrupted
                print("Failed to decode cache data: \(error)")
            }
        }
        
        // Build URL with offset for pagination
        guard let url = URL(string: "\(baseURL)?offset=\(offset)&limit=50") else {  // Added `limit=50`
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
                
                // Cache data if it's the first page
                if offset == 0 {
                    UserDefaults.standard.set(data, forKey: self.cacheKey)
                }
                
                completion(.success(exercises))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Clear Cache Method
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }
}














