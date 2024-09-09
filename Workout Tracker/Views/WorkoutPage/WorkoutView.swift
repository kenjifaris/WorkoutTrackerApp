//
//  WorkoutView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct WorkoutView: View {
    @State private var isActiveWorkoutPresented = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Quick Start Section (Removed extra "Start Workout")
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Start")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Button(action: {
                            isActiveWorkoutPresented = true
                        }) {
                            Text("Start an Empty Workout")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $isActiveWorkoutPresented) {
                            ActiveWorkoutView()
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Templates Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Templates")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        // My Templates
                        Text("My Templates (0)")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        // Add New Template Button
                        Button(action: {
                            // Add new template action
                        }) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.1))
                                .frame(height: 100)
                                .overlay(
                                    Text("Tap to Add New Template")
                                        .foregroundColor(.blue)
                                        .fontWeight(.bold)
                                )
                                .padding(.horizontal)
                        }
                        
                        // Example Templates
                        Text("Example Templates (\(SampleWorkoutTemplates.templates.count))")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(SampleWorkoutTemplates.templates) { template in
                                WorkoutTemplateCardView(template: template)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Start Workout")
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
    }
}












