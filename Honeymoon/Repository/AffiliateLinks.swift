//
//  AffiliateLinks.swift
//  Honeymoon
//
//  Builds outbound search URLs for hotels and experiences at a destination.
//  These are the real revenue engine: a single booking commission dwarfs the IAP.
//  Links default to two travellers (it's a honeymoon) and accept an optional
//  travel date so they can deep-link to the couple's actual dates.
//
//  Stage C: drop your affiliate identifiers into the two constants below after
//  signing up for the Booking.com and GetYourGuide partner programs. Call sites
//  don't change — the IDs are appended automatically when set.
//

import Foundation

enum AffiliateLinks {

    // Set these to your real affiliate identifiers after partner sign-up.
    private static let bookingAffiliateID: String? = nil
    private static let getYourGuidePartnerID: String? = nil
    private static let insurancePartnerID: String? = nil

    /// Booking.com hotel search for the destination, scoped to two adults and
    /// (optionally) the couple's travel dates.
    static func hotels(for destination: Destination, checkIn: Date? = nil, nights: Int = 5) -> URL? {
        let query = "\(destination.place) \(destination.country)"
        var components = URLComponents(string: "https://www.booking.com/searchresults.html")
        var items = [
            URLQueryItem(name: "ss", value: query),
            URLQueryItem(name: "group_adults", value: "2"),
            URLQueryItem(name: "no_rooms", value: "1")
        ]
        if let checkIn {
            let checkout = Calendar.current.date(byAdding: .day, value: max(nights, 1), to: checkIn) ?? checkIn
            items.append(URLQueryItem(name: "checkin", value: dateFormatter.string(from: checkIn)))
            items.append(URLQueryItem(name: "checkout", value: dateFormatter.string(from: checkout)))
        }
        if let bookingAffiliateID { items.append(URLQueryItem(name: "aid", value: bookingAffiliateID)) }
        components?.queryItems = items
        return components?.url
    }

    /// GetYourGuide experiences search for the destination.
    static func experiences(for destination: Destination) -> URL? {
        let encoded = destination.place.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? destination.place
        var components = URLComponents(string: "https://www.getyourguide.com/s/")
        var items = [URLQueryItem(name: "q", value: encoded)]
        if let getYourGuidePartnerID { items.append(URLQueryItem(name: "partner_id", value: getYourGuidePartnerID)) }
        components?.queryItems = items
        return components?.url
    }

    /// Travel-insurance quote link for the trip — couples-friendly default of two
    /// travellers, deep-linking the travel dates when known. Ties into the
    /// readiness checklist's "Travel insurance" item. Set `insurancePartnerID`
    /// after signing up for a travel-insurance affiliate program.
    static func travelInsurance(checkIn: Date? = nil, nights: Int = 7) -> URL? {
        var components = URLComponents(string: "https://www.worldnomads.com/travel-insurance")
        var items = [URLQueryItem(name: "travellers", value: "2")]
        if let checkIn {
            let end = Calendar.current.date(byAdding: .day, value: max(nights, 1), to: checkIn) ?? checkIn
            items.append(URLQueryItem(name: "startDate", value: dateFormatter.string(from: checkIn)))
            items.append(URLQueryItem(name: "endDate", value: dateFormatter.string(from: end)))
        }
        if let insurancePartnerID { items.append(URLQueryItem(name: "affiliate", value: insurancePartnerID)) }
        components?.queryItems = items
        return components?.url
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
