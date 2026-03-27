//
//  ShortlistItem.swift
//  G2_4Rent
//
//  Created by Rajan Gurungq on 2024-11-08.
//

import Foundation

struct ShortlistItem: Identifiable, Codable {
    var id: String
    var tenantID: String
    var propertyID: String
    var dateAdded: Date
    var priority: Int
    var notes: String?
    var lastUpdated: Date?

    init(id: String, tenantID: String, propertyID: String, priority: Int = 1, notes: String? = nil) {
        self.id = id
        self.tenantID = tenantID
        self.propertyID = propertyID
        dateAdded = Date()
        self.priority = priority
        self.notes = notes
    }
}
