//
//  Request.swift
//  G2_4Rent
//
//  Created by Rajan Gurungq on 2024-11-08.
//

import Foundation

enum RequestStatus: String, Codable, CaseIterable {
    case pending
    case approved
    case denied
}

struct Request: Identifiable, Codable {
    var id: String
    var requesterID: String
    var propertyID: String
    var landlordID: String
    var status: RequestStatus
    var requestDate: Date
    var responseDate: Date?
    var message: String?

    init(id: String, requesterID: String, propertyID: String, landlordID: String, message: String? = nil) {
        self.id = id
        self.requesterID = requesterID
        self.propertyID = propertyID
        self.landlordID = landlordID
        self.message = message
        status = .pending
        requestDate = Date()
    }

    init(
        id: String,
        requesterID: String,
        propertyID: String,
        landlordID: String,
        status: RequestStatus,
        requestDate: Date,
        responseDate: Date?,
        message: String?
    ) {
        self.id = id
        self.requesterID = requesterID
        self.propertyID = propertyID
        self.landlordID = landlordID
        self.status = status
        self.requestDate = requestDate
        self.responseDate = responseDate
        self.message = message
    }
}
