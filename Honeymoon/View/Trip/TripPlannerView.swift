//
//  TripPlannerView.swift
//  Honeymoon
//
//  P3: the planning dashboard for one booked destination — countdown, budget
//  tracker, packing checklist, and notes. Backed by TripPlanStore (Firestore).
//

import SwiftUI

struct TripPlannerView: View {

    @StateObject private var store: TripPlanStore

    @State private var newBudgetTitle = ""
    @State private var newBudgetAmount = ""
    @State private var newChecklistTitle = ""
    @AppStorage("currency") private var currencyRaw = Currency.sgd.rawValue
    @AppStorage("tripRemindersEnabled") private var tripRemindersEnabled = true

    init(booking: BookingItem) {
        let seed = TripPlan(
            destinationId: booking.id,
            place: booking.place,
            country: booking.country,
            image: booking.image
        )
        _store = StateObject(wrappedValue: TripPlanStore(seed: seed))
    }

    private var plan: TripPlan { store.plan }

    var body: some View {
        List {
            headerSection
            countdownSection
            budgetSection
            checklistSection
            notesSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(plan.place)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                    )
                }
                .fontWeight(.semibold)
            }
        }
        .task {
            await store.load()
            refreshReminders()
        }
    }

    /// Schedules or clears the trip's countdown notifications based on the date
    /// and the user's reminders preference.
    private func refreshReminders() {
        guard tripRemindersEnabled, let date = plan.startDate else {
            NotificationService.shared.cancel(destinationId: plan.destinationId)
            return
        }
        Task {
            await NotificationService.shared.scheduleCountdown(
                destinationId: plan.destinationId,
                place: plan.place,
                startDate: date
            )
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        Section {
            HStack(spacing: 14) {
                Image(plan.image)
                    .resizable().scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.place).font(.title3.weight(.semibold))
                    Text(plan.country).font(.subheadline).foregroundStyle(.secondary)
                    if store.isShared {
                        Label("Shared with your partner", systemImage: "person.2.fill")
                            .font(.caption)
                            .foregroundStyle(Color.brand)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Countdown

    private var dateBinding: Binding<Date> {
        Binding(
            get: { plan.startDate ?? defaultStartDate },
            set: { store.setStartDate($0); refreshReminders() }
        )
    }

    private var defaultStartDate: Date {
        Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    }

    private var countdownSection: some View {
        Section("When") {
            if plan.startDate == nil {
                Button {
                    store.setStartDate(defaultStartDate)
                    refreshReminders()
                } label: {
                    Label("Set travel date", systemImage: "calendar.badge.plus")
                }
            } else {
                HStack {
                    Image(systemName: "calendar.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.brand)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(countdownText).font(.headline)
                        Text("Travel date").font(.caption).foregroundStyle(.secondary)
                    }
                }
                DatePicker("Date", selection: dateBinding, displayedComponents: .date)
                    .datePickerStyle(.compact)
                Button("Clear date", role: .destructive) {
                    store.setStartDate(nil)
                    refreshReminders()
                }
            }
        }
    }

    private var countdownText: String {
        guard let days = plan.daysUntilStart else { return "—" }
        switch days {
        case let d where d > 1: return "\(d) days to go"
        case 1: return "Tomorrow!"
        case 0: return "Today — bon voyage!"
        case -1: return "Yesterday"
        default: return "\(-days) days ago"
        }
    }

    // MARK: - Budget

    private var budgetSection: some View {
        Section {
            ForEach(plan.budgetItems) { item in
                HStack {
                    Text(item.title)
                    Spacer()
                    Text(currency(item.amountUSD)).foregroundStyle(.secondary)
                }
            }
            .onDelete { store.removeBudgetItems(at: $0) }

            HStack(spacing: 8) {
                TextField("Item", text: $newBudgetTitle)
                TextField("\(Currency.current.symbol)0", text: $newBudgetAmount)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 90)
                Button {
                    addBudgetItem()
                } label: {
                    Image(systemName: "plus.circle.fill").foregroundStyle(Color.brand)
                }
                .disabled(newBudgetTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        } header: {
            Text("Budget")
        } footer: {
            if !plan.budgetItems.isEmpty {
                HStack {
                    Text("Total").fontWeight(.semibold)
                    Spacer()
                    Text(currency(plan.budgetTotal)).fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(.primary)
            }
        }
    }

    private func addBudgetItem() {
        let typed = Double(newBudgetAmount.replacingOccurrences(of: ",", with: "")) ?? 0
        // The field is in the display currency; store the USD base.
        store.addBudgetItem(title: newBudgetTitle, amount: Currency.current.usd(fromAmount: typed))
        newBudgetTitle = ""
        newBudgetAmount = ""
    }

    // MARK: - Checklist

    private var checklistSection: some View {
        Section {
            if !plan.checklist.isEmpty {
                ProgressView(value: plan.checklistProgress)
                    .tint(Color.brand)
            }
            ForEach(plan.checklist) { item in
                HStack(spacing: 8) {
                    Button {
                        store.toggleChecklistItem(item)
                    } label: {
                        HStack {
                            Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.done ? Color.brand : Color(.tertiaryLabel))
                            Text(item.title)
                                .strikethrough(item.done)
                                .foregroundStyle(item.done ? .secondary : .primary)
                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    // Revenue tie-in: a quote link on the unchecked insurance item.
                    if item.title == TripPlan.travelInsuranceItem, !item.done,
                       let url = AffiliateLinks.travelInsurance(checkIn: plan.startDate) {
                        Link(destination: url) {
                            Text("Get a quote")
                                .font(.caption.weight(.semibold))
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(Color.brand)
                    }
                }
            }
            .onDelete { store.removeChecklistItems(at: $0) }

            HStack(spacing: 8) {
                TextField("Add a checklist item", text: $newChecklistTitle)
                Button {
                    addChecklistItem()
                } label: {
                    Image(systemName: "plus.circle.fill").foregroundStyle(Color.brand)
                }
                .disabled(newChecklistTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if missingEssentialsCount > 0 {
                Button {
                    addEssentials()
                } label: {
                    Label(
                        plan.checklist.isEmpty ? "Add trip essentials" : "Add \(missingEssentialsCount) more essentials",
                        systemImage: "sparkles"
                    )
                }
                .foregroundStyle(Color.brand)
            }
        } header: {
            Text("Trip readiness")
        } footer: {
            Text("Tip: most countries need your passport valid for 6+ months beyond your trip.")
        }
    }

    private var missingEssentialsCount: Int {
        let existing = Set(plan.checklist.map(\.title))
        return TripPlan.honeymoonEssentials.filter { !existing.contains($0) }.count
    }

    private func addEssentials() {
        let existing = Set(plan.checklist.map(\.title))
        for title in TripPlan.honeymoonEssentials where !existing.contains(title) {
            store.addChecklistItem(title: title)
        }
    }

    private func addChecklistItem() {
        store.addChecklistItem(title: newChecklistTitle)
        newChecklistTitle = ""
    }

    // MARK: - Notes

    private var notesSection: some View {
        Section("Notes") {
            TextEditor(text: $store.plan.notes)
                .frame(minHeight: 120)
                .onChange(of: store.plan.notes) { store.notesChanged() }
        }
    }

    // MARK: - Helpers

    /// `amountUSD` is a USD-base value; formats it in the user's chosen currency.
    private func currency(_ amountUSD: Double) -> String {
        Currency.current.format(usd: amountUSD)
    }
}

#Preview {
    NavigationStack {
        TripPlannerView(booking: BookingItem(
            id: "veligandu-maldives", place: "Veligandu", country: "Maldives",
            image: "photo-veligandu-island-maldives", bookedAt: Date()
        ))
    }
}
