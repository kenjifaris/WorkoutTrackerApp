//
//  Exercise.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import Foundation

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let imageName: String
}

