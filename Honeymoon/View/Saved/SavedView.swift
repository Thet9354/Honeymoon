//
//  SavedView.swift
//  Honeymoon
//

import SwiftUI

struct SavedView: View {

    @EnvironmentObject private var userDataStore: UserDataStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if userDataStore.favorites.isEmpty && userDataStore.bookings.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .tint(Color.pink)
        }
    }

    private var list: some View {
        List {
            if !userDataStore.favorites.isEmpty {
                Section("Favorites") {
                    ForEach(userDataStore.favorites) { item in
                        row(image: item.image, place: item.place, country: item.country)
                    }
                    .onDelete { offsets in
                        offsets.map { userDataStore.favorites[$0].id }
                            .forEach(userDataStore.removeFavorite)
                    }
                }
            }

            if !userDataStore.bookings.isEmpty {
                Section("Bookings") {
                    ForEach(userDataStore.bookings) { item in
                        row(image: item.image, place: item.place, country: item.country, booked: true)
                    }
                    .onDelete { offsets in
                        offsets.map { userDataStore.bookings[$0].id }
                            .forEach(userDataStore.removeBooking)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func row(image: String, place: String, country: String, booked: Bool = false) -> some View {
        HStack(spacing: 14) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(place)
                    .font(.headline)
                Text(country)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if booked {
                Image(systemName: "airplane.circle.fill")
                    .foregroundStyle(Color.pink)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(place), \(country)\(booked ? ", booked" : "")")
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Color.pink.opacity(0.6))
            Text("Nothing saved yet")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
            Text("Swipe right on a destination to save it, or tap Book Destination to plan a trip.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    SavedView()
        .environmentObject(UserDataStore())
}
