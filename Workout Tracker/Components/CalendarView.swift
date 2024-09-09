//
//  CalendarView.swift
//  Workout Tracker
//
//  Created by Kenji  on 8/19/24.
//

import SwiftUI

struct CalendarView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()
    @State private var currentMonth: Date = Date()

    // MARK: - Date Formatter
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    // MARK: - Grid Layout for Calendar
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)

    var body: some View {
        NavigationView {
            VStack {
                // Month and navigation
                HStack {
                    Button(action: {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? Date()
                    }) {
                        Image(systemName: "chevron.left")
                            .padding(.horizontal)
                    }

                    Spacer()

                    Text(dateFormatter.string(from: currentMonth))
                        .font(.headline)
                        .padding()

                    Spacer()

                    Button(action: {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? Date()
                    }) {
                        Image(systemName: "chevron.right")
                            .padding(.horizontal)
                    }
                }
                .padding()

                // Days of the week header
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Calendar dates
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(daysInMonth(for: currentMonth), id: \.self) { date in
                        if let date = date {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(date == selectedDate ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(10)
                                .onTapGesture {
                                    selectedDate = date
                                }
                        } else {
                            // Empty space for aligning days
                            Text("")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Calendar")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    // MARK: - Days of the Week
    private var daysOfWeek: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.shortWeekdaySymbols
    }

    // MARK: - Days in Month
    private func daysInMonth(for date: Date) -> [Date?] {
        guard let range = Calendar.current.range(of: .day, in: .month, for: date),
              let firstOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date)),
              let firstWeekday = Calendar.current.dateComponents([.weekday], from: firstOfMonth).weekday else {
            return []
        }

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        days.append(contentsOf: range.compactMap { day -> Date in
            return Calendar.current.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
        })

        return days
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}



