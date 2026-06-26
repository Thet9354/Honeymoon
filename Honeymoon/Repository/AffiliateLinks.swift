//
//  AffiliateLinks.swift
//  Honeymoon
//
//  Builds outbound search URLs for hotels and experiences at a destination.
//  P1 ships plain (non-affiliate) search links so the buttons are immediately
//  useful. P5 (monetization) adds affiliate IDs here — call sites don't change.
//

import Foundation

enum AffiliateLinks {

    // P5: set these to your real affiliate identifiers, then append them as
    // query parameters in the builders below.
    private static let bookingAffiliateID: String? = nil
    private static let getYourGuidePartnerID: String? = nil

    /// Booking.com hotel search for the destination.
    static func hotels(for destination: Destination) -> URL? {
        let query = "\(destination.place) \(destination.country)"
        var components = URLComponents(string: "https://www.booking.com/searchresults.html")
        var items = [URLQueryItem(name: "ss", value: query)]
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
}
