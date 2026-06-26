//
//  Couple.swift
//  Honeymoon
//
//  P4: two linked partners. The couple is stored at couples/{coupleId} with the
//  member UIDs and a short invite code; a lookup doc at invites/{CODE} lets a
//  partner join by typing the code. Mutual likes (both members liked the same
//  destination) become matches.
//

import Foundation

struct Couple: Codable, Equatable {
    var members: [String]
    var inviteCode: String
}

/// A destination both partners liked.
struct CoupleMatch: Identifiable, Hashable {
    let id: String          // destination id
    let place: String
    let country: String
    let image: String
}
