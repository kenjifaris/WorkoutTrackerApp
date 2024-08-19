//
//  HistoryView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct HistoryView: View {
    @State private var isCalendarPresented = false
    @State private var isWorkoutViewPresented = false

    var body: some View {
        NavigationView {
            VStack {
                // Placeholder for no workouts
                Spacer()
                
                Image(systemName: "bird.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                
                Text("No Workouts Performed")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                
                Text("Completed workouts will appear here.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                // Start Workout Button
                Button(action: {
                    isWorkoutViewPresented = true
                }) {
                    Text("+ Start Workout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .sheet(isPresented: $isWorkoutViewPresented) {
                    WorkoutView()
                }
                
                Spacer()
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isCalendarPresented = true
                    }) {
                        Text("Calendar")
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $isCalendarPresented) {
                        CalendarView() // We'll define CalendarView later
                    }
                }
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}




