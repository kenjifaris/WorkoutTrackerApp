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
                // Timer button
                Button(action: {
                    // Timer functionality if needed
                }) {
                    Image(systemName: "timer")
                        .font(.title)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }

                Spacer()

                // Workout name and timer
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
                    VStack(alignment: .leading, spacing: 10) {
                        // Exercise name with a link to the detail view
                        HStack {
                            NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                Text(exercise.name)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }

                            Spacer()

                            // Link icon for additional info
                            Button(action: {
                                // Action for linking exercise info (e.g., show history)
                            }) {
                                Image(systemName: "link")
                                    .foregroundColor(.blue)
                            }

                            // Three-dot button for more options
                            Button(action: {
                                // Action for more options
                            }) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.gray)
                            }
                        }

                        // Set rows for each exercise
                        if let sets = exerciseSets[exercise.id], !sets.isEmpty {
                            ForEach(sets.indices, id: \.self) { index in
                                HStack {
                                    Text("Set \(sets[index].setNumber)")
                                        .font(.subheadline)

                                    Spacer()

                                    // Display "Previous" values (placeholder for now)
                                    Text("-")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    // TextField for lbs (weight) with binding
                                    if let weightBinding = bindingForSetWeight(exerciseID: exercise.id, index: index) {
                                        TextField("lbs", text: weightBinding)
                                            .frame(width: 60)
                                            .keyboardType(.decimalPad)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }

                                    // TextField for reps with binding
                                    if let repsBinding = bindingForSetReps(exerciseID: exercise.id, index: index) {
                                        TextField("Reps", text: repsBinding)
                                            .frame(width: 60)
                                            .keyboardType(.numberPad)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }

                                    Spacer()

                                    // Checkmark button
                                    Button(action: {
                                        // Confirm set action (e.g., mark as completed)
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
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 5)
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
                // Present ExercisesSelectionView and pass back selected exercises
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
            workoutDuration += 1
        }
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

// Preview provider
struct ActiveWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveWorkoutView(selectedExercises: [
            ExerciseModel(id: "0001", name: "Bench Press (Smith Machine)", target: "Chest", bodyPart: "Chest", equipment: "Smith Machine", category: "Strength", gifFileName: "0001.gif", secondaryMuscles: ["Triceps"], instructions: ["Lift the weight."]),
            ExerciseModel(id: "0002", name: "Bench Press (Dumbbell)", target: "Chest", bodyPart: "Chest", equipment: "Dumbbell", category: "Strength", gifFileName: "0002.gif", secondaryMuscles: ["Triceps"], instructions: ["Lift the dumbbells."])
        ])
    }
}











