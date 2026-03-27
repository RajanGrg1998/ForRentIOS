//
//  Property.swift
//  G2_4Rent
//
//  Created by Rajan Gurungq on 2024-11-08.
//

import Foundation

struct Property: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var address: String
    var price: Double
    var landlordID: String
    var isListed: Bool = true
    var listedDate: Date = Date()

    // Additional fields
    var imageURLs: [String] = []
    var bedrooms: Int = 0
    var bathrooms: Int = 0
    var amenities: [String] = []
    var latitude: Double?
    var longitude: Double?
    var availabilityDate: Date?
    var ratings: Double?

    init(id: String, title: String, description: String, address: String, price: Double, landlordID: String, isListed: Bool = true, listedDate: Date = Date(), imageURLs: [String] = [], bedrooms: Int = 0, bathrooms: Int = 0, amenities: [String] = [], latitude: Double? = nil, longitude: Double? = nil, availabilityDate: Date? = nil, ratings: Double? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.address = address
        self.price = price
        self.landlordID = landlordID
        self.isListed = isListed
        self.listedDate = listedDate
        self.imageURLs = imageURLs
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.amenities = amenities
        self.latitude = latitude
        self.longitude = longitude
        self.availabilityDate = availabilityDate
        self.ratings = ratings
    }
}
