//
//  Currency.swift
//  Honeymoon
//
//  P6: app-wide display currency. All monetary values are stored in a USD base
//  and converted for display (and entry) into the user's chosen currency.
//  Defaults to SGD; switchable to USD in Settings. The conversion rate is a
//  static, indicative constant — budgets here are estimates, not live quotes.
//

import Foundation

enum Currency: String, CaseIterable, Identifiable {
    case sgd
    case usd

    var id: String { rawValue }
    var code: String { rawValue.uppercased() }

    var symbol: String {
        switch self {
        case .sgd: "S$"
        case .usd: "US$"
        }
    }

    var label: String {
        switch self {
        case .sgd: "Singapore Dollar (S$)"
        case .usd: "US Dollar (US$)"
        }
    }

    /// Indicative USD→SGD rate. Update this single constant if it drifts.
    static let usdToSgd: Double = 1.35

    /// Converts a USD-base amount into this currency.
    func amount(fromUSD usd: Double) -> Double {
        self == .usd ? usd : usd * Self.usdToSgd
    }

    /// Converts an amount entered in this currency back to the USD base.
    func usd(fromAmount amount: Double) -> Double {
        self == .usd ? amount : amount / Self.usdToSgd
    }

    /// Formats a USD-base amount in this currency, e.g. "S$5,130".
    func format(usd: Double) -> String {
        let value = amount(fromUSD: usd)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        let number = formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
        return "\(symbol)\(number)"
    }

    /// The user's selected currency, read from UserDefaults. Defaults to SGD.
    /// Views that show money should also hold `@AppStorage("currency")` so they
    /// re-render when this changes.
    static var current: Currency {
        Currency(rawValue: UserDefaults.standard.string(forKey: "currency") ?? "") ?? .sgd
    }
}
