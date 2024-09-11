//
//  ExercisesListView.swift
//  Workout Tracker
//
//  Created by Kenji on 9/11/24.
//

import SwiftUI

struct ExercisesListView: View {
    @Binding var selectedExercises: [ExerciseModel]
    @Binding var exerciseSets: [String: [ExerciseSet]]
    @Binding var showingProgressChart: Bool
    @Binding var progressData: [ExerciseSet]
    @Binding var selectedExerciseForActionSheet: ExerciseModel?
    @Binding var selectedExerciseForDetail: ExerciseModel?

    var loadProgressData: (ExerciseModel, @escaping ([ExerciseSet]) -> Void) -> Void
    var addNewSet: (ExerciseModel) -> Void
    var removeSet: (ExerciseModel, Int) -> Void
    var removeExercise: (ExerciseModel) -> Void

    var body: some View {
        VStack(spacing: 20) {
            ForEach(selectedExercises) { exercise in
                VStack {
                    HStack {
                        // Show exercise name and details on tap
                        Button(action: {
                            loadProgressData(exercise) { progress in
                                progressData = progress
                                selectedExerciseForDetail = exercise
                            }
                        }) {
                            Text(exercise.name)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }

                        Spacer()

                        // Ellipsis button for exercise options
                        Button(action: {
                            selectedExerciseForActionSheet = exercise
                        }) {
                            Image(systemName: "ellipsis")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .buttonStyle(BorderlessButtonStyle())
                        .zIndex(1)
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
                    if let sets = exerciseSets[exercise.id], !sets.isEmpty {
                        ForEach(sets.indices, id: \.self) { index in
                            SwipeToDeleteView(onDelete: {
                                removeSet(exercise, index) // Correct argument usage
                            }) {
                                HStack {
                                    Text("Set \(sets[index].setNumber)")
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text("-")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    TextField("lbs", text: Binding(
                                        get: { sets[index].weightString },
                                        set: { newValue in
                                            exerciseSets[exercise.id]?[index].weightString = newValue
                                        }
                                    ))
                                    .frame(width: 60)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                    TextField("Reps", text: Binding(
                                        get: { sets[index].repsString },
                                        set: { newValue in
                                            exerciseSets[exercise.id]?[index].repsString = newValue
                                        }
                                    ))
                                    .frame(width: 60)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                            }
                        }
                    } else {
                        Text("No sets added yet.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // Add Set Button
                    Button(action: {
                        addNewSet(exercise)
                    }) {
                        Text("+ Add Set")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }

                    // Button to show progress chart for the current exercise
                    Button(action: {
                        showingProgressChart = true // Trigger the chart display
                    }) {
                        Text("Show Progress Chart")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                    }
                    .sheet(isPresented: $showingProgressChart) {
                        // Pass only progressData to ExerciseProgressChartView
                        ExerciseProgressChartView(progressData: progressData)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                .onAppear {
                    if exerciseSets[exercise.id]?.isEmpty ?? true {
                        addNewSet(exercise)
                    }
                }
            }
        }
    }
}

