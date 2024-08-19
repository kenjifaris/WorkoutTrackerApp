//
//  MainTabView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
            
            WorkoutView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Workout")
                }
            
            ExercisesView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Exercises")
                }
            
            MeasureView()
                .tabItem {
                    Image(systemName: "ruler.fill")
                    Text("Measure")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}



