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
    @State private var showingActionSheetForExercise: ExerciseModel? = nil // Track which exercise is being managed

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
                    Text(workoutName)
                        .font(.title)
                        .fontWeight(.bold)

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

            // Display selected exercises and sets
            List {
                ForEach(selectedExercises) { exercise in
                    Section(header: HStack {
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundColor(.blue)

                        Spacer()

                        // Ellipsis Button for Additional Options
                        Button(action: {
                            showingActionSheetForExercise = exercise // Show action sheet for this exercise
                        }) {
                            Image(systemName: "ellipsis")
                                .padding()
                                .background(Color.gray.opacity(0.2)) // Add background box for better visibility
                                .cornerRadius(5)
                        }
                        .buttonStyle(BorderlessButtonStyle()) // Prevents row tap on button click
                    }) {
                        // Table Headers aligned correctly with text fields
                        HStack {
                            Text("Set")
                                .font(.caption)
                                .fontWeight(.bold)
                            Spacer()
                            Text("Previous")
                                .font(.caption)
                                .fontWeight(.bold)
                            Spacer()
                            Text("lbs")
                                .font(.caption)
                                .fontWeight(.bold)
                                .frame(width: 60) // Ensures alignment with the lbs text fields
                            Text("Reps")
                                .font(.caption)
                                .fontWeight(.bold)
                                .frame(width: 60) // Ensures alignment with the Reps text fields
                        }
                        .padding(.horizontal)

                        // Display all sets for each exercise
                        if let sets = exerciseSets[exercise.id], !sets.isEmpty {
                            ForEach(sets.indices, id: \.self) { index in
                                HStack {
                                    Text("Set \(sets[index].setNumber)")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("-") // Placeholder for "Previous"
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    TextField("lbs", text: bindingForSetWeight(exerciseID: exercise.id, index: index) ?? .constant(""))
                                        .frame(width: 60)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    TextField("Reps", text: bindingForSetReps(exerciseID: exercise.id, index: index) ?? .constant(""))
                                        .frame(width: 60)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    Spacer()
                                    Button(action: {
                                        // Action for marking set as completed
                                    }) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        } else {
                            Text("No sets added yet.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
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
                    .onAppear {
                        // Ensure there's a default first set when an exercise is added
                        if exerciseSets[exercise.id]?.isEmpty ?? true {
                            addNewSet(for: exercise)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())

            // Add Exercises Button
            Button(action: {
                isExercisesViewPresented = true
            }) {
                Text("Add Exercises")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .sheet(isPresented: $isExercisesViewPresented) {
                ExercisesSelectionView(selectedExercises: $selectedExercises)
            }

            // Cancel Workout Button
            Button(action: {
                // Cancel workout functionality
            }) {
                Text("Cancel Workout")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

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
        // Action Sheet for Exercise Options
        .actionSheet(item: $showingActionSheetForExercise) { exercise in
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
                    .default(Text("Auto Rest Timer")) {
                        // Auto rest timer toggle functionality
                    },
                    .default(Text("Weight Unit: lbs")) {
                        // Change weight unit functionality
                    },
                    .default(Text("Bar Type: None")) {
                        // Bar type setting
                    },
                    .default(Text("PR Metric: Weight")) {
                        // PR Metric selection
                    },
                    .destructive(Text("Remove Exercise")) {
                        removeExercise(exercise) // Remove the exercise
                    },
                    .cancel()
                ]
            )
        }
    }

    // Toggle timer start/stop
    private func toggleTimer() {
        isTimerRunning.toggle()
    }

    // Add a new set for a specific exercise
    private func addNewSet(for exercise: ExerciseModel) {
        let newSetNumber = (exerciseSets[exercise.id]?.count ?? 0) + 1
        let newSet = ExerciseSet(setNumber: newSetNumber)

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















