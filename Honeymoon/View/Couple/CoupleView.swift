//
//  CoupleView.swift
//  Honeymoon
//
//  P4: link with a partner (create or join by code) and see the destinations
//  you've both liked.
//

import SwiftUI

struct CoupleView: View {

    @EnvironmentObject private var coupleStore: CoupleStore
    @Environment(\.dismiss) private var dismiss

    @State private var joinCode = ""

    var body: some View {
        NavigationStack {
            Group {
                if coupleStore.isLinked {
                    linkedState
                } else if coupleStore.isAwaitingPartner {
                    awaitingState
                } else {
                    unlinkedState
                }
            }
            .navigationTitle("Couple Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .tint(Color.brand)
            .alert(
                "Something went wrong",
                isPresented: Binding(
                    get: { coupleStore.errorMessage != nil },
                    set: { if !$0 { coupleStore.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(coupleStore.errorMessage ?? "")
            }
        }
        .appAppearance()
    }

    // MARK: - Unlinked

    private var unlinkedState: some View {
        ScrollView {
            VStack(spacing: 24) {
                hero(
                    icon: "heart.circle.fill",
                    title: "Plan together",
                    subtitle: "Link with your partner and we'll show you the destinations you both love."
                )

                Button {
                    Task { await coupleStore.createCouple() }
                } label: {
                    Label("Invite your partner", systemImage: "person.badge.plus")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(coupleStore.isWorking)

                VStack(spacing: 10) {
                    Text("Got a code from your partner?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack {
                        TextField("Enter code", text: $joinCode)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .multilineTextAlignment(.center)
                            .font(.system(.title3, design: .monospaced))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    }
                    Button {
                        Task { await coupleStore.joinCouple(code: joinCode) }
                    } label: {
                        Text("Join")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brand, lineWidth: 1.5))
                    .foregroundStyle(Color.brand)
                    .disabled(joinCode.trimmingCharacters(in: .whitespaces).isEmpty || coupleStore.isWorking)
                }
            }
            .padding(20)
        }
    }

    // MARK: - Awaiting partner

    private var awaitingState: some View {
        ScrollView {
            VStack(spacing: 24) {
                hero(
                    icon: "paperplane.circle.fill",
                    title: "Share your code",
                    subtitle: "Send this code to your partner. Once they enter it, you'll start matching."
                )

                if let code = coupleStore.inviteCode {
                    VStack(spacing: 12) {
                        Text(code)
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .tracking(6)
                            .foregroundStyle(Color.brand)
                        ShareLink(item: "Join me on Honeymoon! Enter code \(code) in Couple Mode to start planning together.") {
                            Label("Share code", systemImage: "square.and.arrow.up")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                }

                ProgressView("Waiting for your partner to join…")
                    .font(.subheadline)

                Button("Cancel invite", role: .destructive) {
                    Task { await coupleStore.leaveCouple() }
                }
                .disabled(coupleStore.isWorking)
            }
            .padding(20)
        }
    }

    // MARK: - Linked

    private var linkedState: some View {
        List {
            Section {
                Label("You're linked!", systemImage: "heart.fill")
                    .foregroundStyle(Color.brand)
                    .font(.headline)
            }

            Section {
                if coupleStore.matches.isEmpty {
                    Text("No matches yet. Keep swiping — when you both like the same place, it'll appear here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(coupleStore.matches) { match in
                        HStack(spacing: 14) {
                            Image(match.image)
                                .resizable().scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(match.place).font(.headline)
                                Text(match.country).font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "heart.fill").foregroundStyle(Color.brand)
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                Text("Your matches")
            }

            Section {
                Button("Unlink", role: .destructive) {
                    Task { await coupleStore.leaveCouple() }
                }
                .disabled(coupleStore.isWorking)
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Helpers

    private func hero(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(Color.brand)
                .symbolRenderingMode(.hierarchical)
            Text(title)
                .font(.system(.title2, design: .rounded).weight(.bold))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }
}

#Preview {
    CoupleView()
        .environmentObject(CoupleStore())
}
