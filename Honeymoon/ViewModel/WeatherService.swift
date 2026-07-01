//
//  WeatherService.swift
//  Honeymoon
//
//  Live weather for the detail screen via Open-Meteo (free, no API key, no signup).
//  Uses the destination's stored coordinates. Purely additive — the screen works
//  fine when this returns nil (offline / error), it just hides the section.
//

import Foundation

/// A compact weather snapshot for a destination: current conditions plus a short
/// daily outlook. Temperatures are already in the user's preferred unit.
struct DestinationWeather {
    struct Day: Identifiable {
        let id: Int
        let date: Date
        let code: Int
        let high: Double
        let low: Double
    }
    let currentTemp: Double
    let currentCode: Int
    let unitSymbol: String
    let days: [Day]
}

enum WeatherService {

    /// Fetches current conditions + a short daily forecast from Open-Meteo.
    /// Returns nil on any error so the caller can simply hide the section.
    static func forecast(latitude: Double, longitude: Double) async -> DestinationWeather? {
        let fahrenheit = Locale.current.measurementSystem == .us
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "forecast_days", value: "3"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "temperature_unit", value: fahrenheit ? "fahrenheit" : "celsius")
        ]
        guard let url = components?.url else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else { return nil }
            let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            return decoded.snapshot(unitSymbol: fahrenheit ? "°F" : "°C")
        } catch {
            return nil
        }
    }
}

// MARK: - WMO weather codes

extension DestinationWeather {
    /// Maps a WMO weather code to an SF Symbol + short label.
    /// See https://open-meteo.com/en/docs (WMO Weather interpretation codes).
    static func presentation(for code: Int) -> (symbol: String, label: String) {
        switch code {
        case 0:                        return ("sun.max.fill", "Clear")
        case 1, 2:                     return ("cloud.sun.fill", "Partly cloudy")
        case 3:                        return ("cloud.fill", "Overcast")
        case 45, 48:                   return ("cloud.fog.fill", "Fog")
        case 51, 53, 55, 56, 57:       return ("cloud.drizzle.fill", "Drizzle")
        case 61, 63, 65, 80, 81, 82:   return ("cloud.rain.fill", "Rain")
        case 66, 67:                   return ("cloud.sleet.fill", "Freezing rain")
        case 71, 73, 75, 77, 85, 86:   return ("cloud.snow.fill", "Snow")
        case 95, 96, 99:               return ("cloud.bolt.rain.fill", "Thunderstorm")
        default:                       return ("cloud.fill", "—")
        }
    }
}

// MARK: - Open-Meteo response

private struct OpenMeteoResponse: Decodable {
    struct Current: Decodable {
        let temperature_2m: Double
        let weather_code: Int
    }
    struct Daily: Decodable {
        let time: [String]
        let weather_code: [Int]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
    }
    let current: Current
    let daily: Daily

    func snapshot(unitSymbol: String) -> DestinationWeather {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        var days: [DestinationWeather.Day] = []
        for i in daily.time.indices {
            days.append(.init(
                id: i,
                date: formatter.date(from: daily.time[i]) ?? Date(),
                code: daily.weather_code[safe: i] ?? 0,
                high: daily.temperature_2m_max[safe: i] ?? 0,
                low: daily.temperature_2m_min[safe: i] ?? 0
            ))
        }
        return DestinationWeather(
            currentTemp: current.temperature_2m,
            currentCode: current.weather_code,
            unitSymbol: unitSymbol,
            days: days
        )
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
