//
//  ActiveWorkoutView.swift
//  Workout Tracker
//
//  Created by Kenji on 8/19/24.
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
    @State private var showingProgressChart = false // State to show progress chart
    @State private var progressData: [ExerciseSet] = [] // Store the progress data for charts

    // Timer to keep track of workout duration
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Custom initializer to accept selected exercises
    init(selectedExercises: [ExerciseModel] = []) {
        _selectedExercises = State(initialValue: selectedExercises)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Timer and Title Row Component
            TimerAndTitleRow(
                isTimerRunning: $isTimerRunning,
                workoutName: $workoutName,
                workoutDuration: $workoutDuration,
                showingWorkoutOptions: $showingWorkoutOptions,
                isEditingWorkoutName: $isEditingWorkoutName,
                newWorkoutName: $newWorkoutName,
                toggleTimer: toggleTimer,
                finishWorkout: finishWorkout
            )

            // Scrollable list of exercises and buttons
            ScrollView {
                ExercisesListView(
                    selectedExercises: $selectedExercises,
                    exerciseSets: $exerciseSets,
                    showingProgressChart: $showingProgressChart,
                    progressData: $progressData,
                    selectedExerciseForActionSheet: $selectedExerciseForActionSheet,
                    selectedExerciseForDetail: $selectedExerciseForDetail,
                    loadProgressData: loadProgressData,
                    addNewSet: addNewSet,
                    removeSet: removeSet,
                    removeExercise: removeExercise
                )

                // Bottom Buttons: Add Exercises and Cancel Workout
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
            .padding(.bottom, 20) // Ensures buttons are not cut off

            // Sheet for selecting exercises
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
        // Show exercise details when an exercise is selected
        .sheet(item: $selectedExerciseForDetail) { exercise in
            ExerciseDetailView(exercise: exercise, progressData: progressData)
        }
        // Action sheet for options for individual exercises
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
        // Action sheet for workout options
        .actionSheet(isPresented: $showingWorkoutOptions) {
            ActionSheet(
                title: Text("Workout Options"),
                buttons: [
                    .default(Text("Edit Workout Name")) {
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
        // Alert for editing workout name
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

    // Finish workout action
    private func finishWorkout() {
        // Logic for finishing workout
    }

    // Fetch progress data for a specific exercise
    private func loadProgressData(for exercise: ExerciseModel, completion: @escaping ([ExerciseSet]) -> Void) {
        // Simulate loading data from the database or Firestore
        let exampleData = [
            ExerciseSet(setNumber: 1, weight: 100, reps: 10),
            ExerciseSet(setNumber: 2, weight: 110, reps: 8),
            ExerciseSet(setNumber: 3, weight: 115, reps: 6)
        ]
        completion(exampleData) // Replace with actual data loaded from Firestore
    }
}


