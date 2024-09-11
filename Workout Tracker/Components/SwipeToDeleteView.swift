//
//  SwipeToDeleteView.swift
//  Workout Tracker
//
//  Created by Kenji  on 9/11/24.
//

import SwiftUI

struct SwipeToDeleteView<Content: View>: View {
    let onDelete: () -> Void
    let content: Content

    @State private var offset: CGFloat = 0

    init(onDelete: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onDelete = onDelete
        self.content = content()
    }

    var body: some View {
        ZStack {
            // The main content, which is swiped
            content
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.width < 0 { // Only allow left swipe
                                offset = gesture.translation.width
                            }
                        }
                        .onEnded { gesture in
                            if gesture.translation.width < -100 { // If swiped far enough, trigger delete
                                withAnimation(.easeInOut) {
                                    onDelete()
                                }
                            } else { // Reset if not swiped far enough
                                withAnimation(.spring()) {
                                    offset = 0
                                }
                            }
                        }
                )
        }
    }
}


