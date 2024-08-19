//
//  ContentView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                Image(systemName: "gearshape.fill")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.trailing, 10)
                
                VStack(alignment: .leading) {
                    Text("Josh Faris")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("0 workouts")
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Text("Dashboard")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}




