//  ActiveWorkoutView.swift
//  Workout Tracker

import SwiftUI
import FirebaseAuth  // To get user ID

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
    @State private var isSavingWorkout = false // State to track workout saving process

    // Timer to keep track of workout duration
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Custom initializer to accept selected exercises
    init(selectedExercises: [ExerciseModel] = []) {
        _selectedExercises = State(initialValue: selectedExercises)
    }

    var body: some View {
        VStack(spacing: 20) {
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
            .padding(.bottom, 20)

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
        .alert(isPresented: $isSavingWorkout) {
            Alert(
                title: Text("Saving Workout"),
                message: Text("Your workout has been saved successfully."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(item: $selectedExerciseForDetail) { exercise in
            ExerciseDetailView(exercise: exercise, progressData: progressData)
        }
        .actionSheet(item: $selectedExerciseForActionSheet) { exercise in
            ActionSheet(
                title: Text("\(exercise.name) Options"),
                buttons: [
                    .default(Text("Add a Note")),
                    .default(Text("Add Warm-up Sets")),
                    .default(Text("Replace Exercise")),
                    .destructive(Text("Remove Exercise")) {
                        removeExercise(exercise)
                    },
                    .cancel()
                ]
            )
        }
        .actionSheet(isPresented: $showingWorkoutOptions) {
            ActionSheet(
                title: Text("Workout Options"),
                buttons: [
                    .default(Text("Edit Workout Name")) {
                        newWorkoutName = workoutName
                        isEditingWorkoutName = true
                    },
                    .default(Text("Adjust Start/End Time")),
                    .default(Text("Add Photo")),
                    .cancel()
                ]
            )
        }
        .alert("Edit Workout Name", isPresented: $isEditingWorkoutName) {
            TextField("Workout Name", text: $newWorkoutName)
            Button("Save") {
                workoutName = newWorkoutName
            }
            Button("Cancel", role: .cancel, action: {})
        }
    }

    // MARK: Highlighted Changes Begin

    // Finish workout action and save it to Firestore
    private func finishWorkout() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        // **Highlight: Convert the weight and reps strings to numbers before saving**
        for (exerciseId, sets) in exerciseSets {
            for i in 0..<sets.count {
                exerciseSets[exerciseId]?[i].convertStringsToValues() // Ensure conversion
            }
        }

        let workout = Workout(
            id: UUID().uuidString, // Unique identifier for the workout
            workoutName: workoutName,
            workoutDuration: workoutDuration,
            exerciseSets: exerciseSets // Pass the dictionary of exerciseSets
        )

        FirestoreService.shared.saveWorkout(workout, for: userId) { error in
            if let error = error {
                print("Error saving workout: \(error.localizedDescription)")
            } else {
                isSavingWorkout = true // Show alert after saving
            }
        }
    }

    // MARK: Highlighted Changes End

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

        if exerciseSets[exercise.id] != nil {
            exerciseSets[exercise.id]?.append(newSet)
        } else {
            exerciseSets[exercise.id] = [newSet]
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

    // Remove exercise from the list
    private func removeExercise(_ exercise: ExerciseModel) {
        selectedExercises.removeAll { $0.id == exercise.id }
        exerciseSets[exercise.id] = nil
    }

    // Fetch progress data for a specific exercise
    private func loadProgressData(for exercise: ExerciseModel, completion: @escaping ([ExerciseSet]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User ID not found!")
            completion([]) // Return an empty set if user ID is not found
            return
        }
        
        print("Fetching workouts for user: \(userId)") // Log the user ID
        
        FirestoreService.shared.fetchUserWorkouts(for: userId) { result in
            switch result {
            case .success(let workouts):
                // **Log the number of workouts fetched**
                print("Successfully fetched \(workouts.count) workouts from Firestore.")
                
                var progressSets: [ExerciseSet] = []
                
                for workout in workouts {
                    if let sets = workout.exerciseSets[exercise.id] {
                        // **Log the sets that are found for the exercise**
                        print("Found \(sets.count) sets for exercise: \(exercise.name)")
                        progressSets.append(contentsOf: sets) // Collect all sets for the exercise
                    }
                }
                
                if progressSets.isEmpty {
                    print("No progress data found for exercise: \(exercise.name).")
                }
                
                // **Log the progress data being returned**
                print("Returning \(progressSets.count) progress sets for the chart.")
                completion(progressSets) // Return all sets across workouts for this exercise
                
            case .failure(let error):
                print("Error fetching progress data: \(error.localizedDescription)")
                completion([]) // Return an empty array in case of error
            }
        }
    }



}
