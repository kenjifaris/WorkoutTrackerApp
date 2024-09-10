//
//  ActiveWorkoutView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct ActiveWorkoutView: View {
    @State private var workoutName: String = "Midday Workout"
    @State private var workoutDuration: TimeInterval = 0
    @State private var exerciseSets: [String: [ExerciseSet]] = [:] // Store sets for each exercise by exercise id
    @State private var isExercisesViewPresented = false
    @State private var selectedExercises: [ExerciseModel]
    @State private var isTimerRunning = true // Track timer state
    @State private var selectedExerciseForActionSheet: ExerciseModel? = nil // Track which exercise's ActionSheet is displayed
    @State private var showingWorkoutOptions = false // Track whether to show workout options (for workout name ellipsis)
    @State private var selectedExerciseForDetail: ExerciseModel? = nil // For showing exercise details
    @State private var isEditingWorkoutName = false // For workout name editing
    @State private var newWorkoutName: String = "" // Temporary storage for editing workout name

    // Timer to keep track of workout duration
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Custom initializer to accept selected exercises
    init(selectedExercises: [ExerciseModel] = []) {
        _selectedExercises = State(initialValue: selectedExercises)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Timer and Title Row
            HStack {
                // Timer button to start/stop
                Button(action: {
                    toggleTimer()
                }) {
                    Image(systemName: isTimerRunning ? "pause.circle" : "play.circle")
                        .font(.title)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }

                Spacer()

                // Workout name and formatted timer
                VStack(alignment: .leading) {
                    HStack {
                        Text(workoutName)
                            .font(.title)
                            .fontWeight(.bold)

                        // Add ellipsis next to the workout name
                        Button(action: {
                            showingWorkoutOptions = true // Show workout options
                        }) {
                            Image(systemName: "ellipsis")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                        .contentShape(Rectangle())  // Make the entire area tappable
                    }

                    Text("\(formatTime(workoutDuration))")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Notes")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Finish workout button
                Button(action: {
                    // Finish workout functionality
                }) {
                    Text("Finish")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)

            // ScrollView to wrap the List and the buttons
            ScrollView {
                VStack(spacing: 20) { // Add spacing between exercises for better separation
                    // Display selected exercises and sets
                    ForEach(selectedExercises) { exercise in
                        VStack {
                            HStack {
                                Button(action: {
                                    selectedExerciseForDetail = exercise // Show exercise details
                                }) {
                                    Text(exercise.name)
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                }

                                Spacer()

                                // Ellipsis button for each exercise
                                Button(action: {
                                    print("Ellipsis button tapped for \(exercise.name)")
                                    selectedExerciseForActionSheet = exercise // Set the specific exercise for the ActionSheet
                                    print("Selected exercise for action sheet: \(selectedExerciseForActionSheet?.name ?? "None")")
                                }) {
                                    Image(systemName: "ellipsis")
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(5)
                                }
                                .frame(width: 44, height: 44) // Ensure the button has enough tappable space
                                .contentShape(Rectangle())  // Ensure the entire button area is tappable
                                .buttonStyle(BorderlessButtonStyle()) // Prevent interference with surrounding gestures
                                .zIndex(1) // Ensure the button is on the topmost layer
                            }

                            // Set Headers
                            HStack {
                                Text("Set")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("Previous")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("lbs")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(width: 60)

                                Text("Reps")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .frame(width: 60)
                            }
                            .padding(.horizontal)

                            // List of sets with swipe-to-delete
                            VStack(spacing: 8) {
                                if let sets = exerciseSets[exercise.id], !sets.isEmpty {
                                    ForEach(sets.indices, id: \.self) { index in
                                        SwipeToDeleteView(
                                            onDelete: { removeSet(for: exercise, at: index) }
                                        ) {
                                            // Content of each set
                                            HStack {
                                                Text("Set \(sets[index].setNumber)")
                                                    .font(.subheadline)
                                                    .frame(maxWidth: .infinity, alignment: .leading)

                                                Text("-")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                    .frame(maxWidth: .infinity, alignment: .leading)

                                                TextField("lbs", text: bindingForSetWeight(exerciseID: exercise.id, index: index) ?? .constant(""))
                                                    .frame(width: 60)
                                                    .keyboardType(.decimalPad)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                                TextField("Reps", text: bindingForSetReps(exerciseID: exercise.id, index: index) ?? .constant(""))
                                                    .frame(width: 60)
                                                    .keyboardType(.numberPad)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                            }
                                            .padding(.vertical, 4)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2) // Shadow for each set
                                        }
                                    }
                                } else {
                                    Text("No sets added yet.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }

                            // Add Set Button
                            Button(action: {
                                addNewSet(for: exercise)
                            }) {
                                Text("+ Add Set")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.white) // Card background
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5) // Card shadow
                        .onAppear {
                            // Automatically add the first set when exercise is added
                            if exerciseSets[exercise.id]?.isEmpty ?? true {
                                addNewSet(for: exercise)
                            }
                        }
                    }

                    // Buttons at the Bottom
                    HStack(spacing: 16) {
                        Button(action: {
                            isExercisesViewPresented = true
                        }) {
                            Text("Add Exercises")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            // Cancel workout functionality
                        }) {
                            Text("Cancel Workout")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20) // Add some bottom padding to ensure buttons aren’t cut off
            }
            .sheet(isPresented: $isExercisesViewPresented) {
                ExercisesSelectionView(selectedExercises: $selectedExercises)
            }
            Spacer()
        }
        .padding(.top)
        .navigationTitle("")
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            if isTimerRunning {
                workoutDuration += 1
            }
        }
        .sheet(item: $selectedExerciseForDetail) { exercise in
            ExerciseDetailView(exercise: exercise) // Show exercise details in a modal sheet
        }
        // Action Sheet for Exercise Options (for individual exercises)
        .actionSheet(item: $selectedExerciseForActionSheet) { exercise in
            ActionSheet(
                title: Text("\(exercise.name) Options"),
                buttons: [
                    .default(Text("Add a Note")) {
                        // Add a note functionality
                    },
                    .default(Text("Add Warm-up Sets")) {
                        // Add warm-up sets functionality
                    },
                    .default(Text("Replace Exercise")) {
                        // Replace exercise functionality
                    },
                    .destructive(Text("Remove Exercise")) {
                        removeExercise(exercise) // Remove the exercise
                    },
                    .cancel()
                ]
            )
        }
        // Action Sheet for Workout Options (for workout name ellipsis)
        .actionSheet(isPresented: $showingWorkoutOptions) {
            ActionSheet(
                title: Text("Workout Options"),
                buttons: [
                    .default(Text("Edit Workout Name")) {
                        // Trigger edit workout name alert
                        newWorkoutName = workoutName
                        isEditingWorkoutName = true
                    },
                    .default(Text("Adjust Start/End Time")) {
                        // Logic to adjust start/end time
                    },
                    .default(Text("Add Photo")) {
                        // Logic to add photo
                    },
                    .cancel()
                ]
            )
        }
        // Edit Workout Name Alert
        .alert("Edit Workout Name", isPresented: $isEditingWorkoutName) {
            TextField("Workout Name", text: $newWorkoutName)
            Button("Save", action: {
                workoutName = newWorkoutName
            })
            Button("Cancel", role: .cancel, action: {})
        }
    }

    // Function to remove a set and re-index remaining sets
    private func removeSet(for exercise: ExerciseModel, at index: Int) {
        guard var sets = exerciseSets[exercise.id] else { return }
        sets.remove(at: index)
        
        // Re-index the sets after deletion
        for i in 0..<sets.count {
            sets[i].setNumber = i + 1
        }
        
        exerciseSets[exercise.id] = sets
    }

    // Toggle timer start/stop
    private func toggleTimer() {
        isTimerRunning.toggle()
    }

    // Add a new set for a specific exercise
    private func addNewSet(for exercise: ExerciseModel) {
        let newSetNumber = (exerciseSets[exercise.id]?.count ?? 0) + 1

        // Get previous set's values (lbs and reps) to auto-fill the new set
        let previousSet = exerciseSets[exercise.id]?.last
        var newSet = ExerciseSet(setNumber: newSetNumber)

        newSet.weightString = previousSet?.weightString ?? "" // Auto-fill weight
        newSet.repsString = previousSet?.repsString ?? ""     // Auto-fill reps

        // Append the new set to the list of sets for this exercise
        if exerciseSets[exercise.id] != nil {
            exerciseSets[exercise.id]?.append(newSet)
        } else {
            exerciseSets[exercise.id] = [newSet]
        }
    }

    // Remove exercise from the list
    private func removeExercise(_ exercise: ExerciseModel) {
        selectedExercises.removeAll { $0.id == exercise.id }
        exerciseSets[exercise.id] = nil
    }

    // Format Time Interval into H:MM:SS format
    private func formatTime(_ totalSeconds: TimeInterval) -> String {
        let seconds = Int(totalSeconds) % 60
        let minutes = (Int(totalSeconds) / 60) % 60
        let hours = Int(totalSeconds) / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // Helper to bind to ExerciseSet's weightString
    private func bindingForSetWeight(exerciseID: String, index: Int) -> Binding<String>? {
        guard let sets = exerciseSets[exerciseID], sets.indices.contains(index) else {
            return nil
        }
        return Binding(
            get: { sets[index].weightString },
            set: { newValue in
                exerciseSets[exerciseID]?[index].weightString = newValue
            }
        )
    }

    // Helper to bind to ExerciseSet's repsString
    private func bindingForSetReps(exerciseID: String, index: Int) -> Binding<String>? {
        guard let sets = exerciseSets[exerciseID], sets.indices.contains(index) else {
            return nil
        }
        return Binding(
            get: { sets[index].repsString },
            set: { newValue in
                exerciseSets[exerciseID]?[index].repsString = newValue
            }
        )
    }
}

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
                            if gesture.translation.width < -100 { // If swiped far enough, delete
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








































