//
//  ExerciseDetailView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/20/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ExerciseDetailView: View {
    var exercise: ExerciseModel

    var body: some View {
        VStack {
            // Display the GIF with a fixed size
            if let gifFileName = exercise.gifFileName,
               let gifPath = Bundle.main.path(forResource: gifFileName, ofType: nil, inDirectory: "360") {
                WebImage(url: URL(fileURLWithPath: gifPath))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 250) // Fixed height for the GIF
                    .padding()
                    .onAppear {
                        print("GIF should be playing from path: \(gifPath)")
                    }
            } else {
                // Fallback in case GIF is not found
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 250) // Fixed height for placeholder as well
                    .padding()
                    .foregroundColor(.gray)
            }
            
            // Scrollable instructions
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Instructions")
                        .font(.headline)
                        .padding(.top)
                    
                    // Numbered instructions with proper alignment
                    ForEach(exercise.instructions?.indices ?? 0..<0, id: \.self) { index in
                        HStack(alignment: .top) {
                            // Number with alignment
                            Text("\(index + 1).")
                                .fontWeight(.bold)
                                .frame(width: 20, alignment: .leading)
                                .alignmentGuide(.top) { _ in 0 }
                            
                            // Instruction text with proper alignment and wrapping
                            Text(exercise.instructions?[index] ?? "")
                                .fixedSize(horizontal: false, vertical: true) // Allows wrapping
                                .alignmentGuide(.top) { _ in 0 }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding([.leading, .trailing], 16) // Add horizontal padding for nicer layout
            }
        }
        .padding(.bottom, 20) // Avoid cutting off content at the bottom
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}











