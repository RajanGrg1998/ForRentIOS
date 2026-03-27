//
//  User.swift
//  G2_4Rent
//
//  Created by Rajan Gurungq on 2024-11-08.
//

import Foundation

enum UserRole: String, Codable {
    case landlord
    case tenant
}

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var contactInfo: String?
    var role: UserRole
    var shortlist: [String] = []

    enum CodingKeys: String, CodingKey {
        case id, name, email, contactInfo, role, shortlist
    }
}
