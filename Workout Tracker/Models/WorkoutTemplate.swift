//
//  WorkoutTemplate.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import Foundation

struct WorkoutTemplate: Identifiable {
    let id = UUID()
    let name: String
    let exercises: String // A simple string for now, can be expanded later
}

