//
//  ItineraryView.swift
//  Honeymoon
//
//  P5: the unlocked Premium itinerary — a day-by-day plan plus a budget
//  breakdown for a destination. Reached from the detail screen once the user
//  has Premium.
//

import SwiftUI

struct ItineraryView: View {

    let destination: Destination
    @Environment(\.dismiss) private var dismiss
    // Held so the budget re-renders when the user switches currency.
    @AppStorage("currency") private var currencyRaw = Currency.sgd.rawValue

    private var itinerary: Itinerary { Itinerary.generate(for: destination) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(itinerary.days.count)-day honeymoon")
                            .font(.title3.weight(.bold))
                        Text("A romantic day-by-day plan for \(destination.place), \(destination.country).")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                ForEach(itinerary.days) { day in
                    Section {
                        beat(icon: "sunrise", label: "Morning", text: day.morning)
                        beat(icon: "sun.max", label: "Afternoon", text: day.afternoon)
                        beat(icon: "moon.stars", label: "Evening", text: day.evening)
                        beat(icon: "fork.knife", label: "Dining", text: day.dining)
                    } header: {
                        Text("Day \(day.dayNumber) · \(day.title)")
                    }
                }

                if !itinerary.budget.isEmpty {
                    Section {
                        ForEach(itinerary.budget) { line in
                            HStack {
                                Text(line.category)
                                Spacer()
                                Text(line.display).foregroundStyle(.secondary)
                            }
                        }
                        HStack {
                            Text("Estimated total").fontWeight(.semibold)
                            Spacer()
                            Text(itinerary.budgetTotalDisplay).fontWeight(.semibold)
                        }
                    } header: {
                        Text("Budget for two")
                    } footer: {
                        Text("Indicative only — actual prices vary by season and how you book.")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(destination.place)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .tint(Color.pink)
        }
    }

    private func beat(icon: String, label: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.pink)
                .frame(width: 24, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(text)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ItineraryView(destination: honeymoonData[0])
}
