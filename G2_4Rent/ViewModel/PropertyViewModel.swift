import FirebaseFirestore
import Foundation

class PropertyViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var landlordProperties: [Property] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func fetchAllProperties() {
        db.collection("properties")
            .whereField("isListed", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = "Error fetching properties: \(error.localizedDescription)"
                    return
                }

                self.properties = snapshot?.documents.compactMap { self.mapDocumentToProperty($0) } ?? []
            }
    }

    func fetchPropertiesByIDs(_ ids: [String], completion: @escaping ([Property]) -> Void) {
        let group = DispatchGroup()
        var fetchedProperties: [Property] = []

        for id in ids {
            group.enter()
            db.collection("properties").document(id).getDocument { document, _ in
                if let document = document, document.exists {
                    if let property = try? document.data(as: Property.self) {
                        fetchedProperties.append(property)
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(fetchedProperties)
        }
    }

    func fetchLandlordProperties(landlordID: String) {
        db.collection("properties")
            .whereField("landlordID", isEqualTo: landlordID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = "Error fetching landlord's properties: \(error.localizedDescription)"
                    return
                }

                self.landlordProperties = snapshot?.documents.compactMap { self.mapDocumentToProperty($0) } ?? []
            }
    }

    func fetchProperty(by id: String, completion: @escaping (Property?) -> Void) {
        db.collection("properties").document(id).getDocument { document, error in
            if let error = error {
                print("Error fetching property: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let document = document, document.exists {
                let property = self.mapDocumentToProperty(document)
                completion(property)
            } else {
                completion(nil)
            }
        }
    }

    func addProperty(_ property: Property, completion: @escaping (Bool) -> Void) {
        let newPropertyRef = db.collection("properties").document(property.id)
        newPropertyRef.setData(propertyToDict(property)) { error in
            if let error = error {
                self.errorMessage = "Error adding property: \(error.localizedDescription)"
                completion(false)
            } else {
                self.fetchLandlordProperties(landlordID: property.landlordID)
                completion(true)
            }
        }
    }

    func updateProperty(_ property: Property, completion: @escaping (Bool) -> Void) {
        let propertyRef = db.collection("properties").document(property.id)
        propertyRef.setData(propertyToDict(property), merge: true) { error in
            if let error = error {
                self.errorMessage = "Error updating property: \(error.localizedDescription)"
                completion(false)
            } else {
                self.fetchLandlordProperties(landlordID: property.landlordID)
                completion(true)
            }
        }
    }

    func deleteProperty(_ property: Property, completion: @escaping (Bool) -> Void) {
        db.collection("properties").document(property.id).delete { error in
            if let error = error {
                self.errorMessage = "Error deleting property: \(error.localizedDescription)"
                completion(false)
            } else {
                self.fetchLandlordProperties(landlordID: property.landlordID)
                completion(true)
            }
        }
    }

    private func mapDocumentToProperty(_ document: DocumentSnapshot) -> Property? {
        let data = document.data() ?? [:]

        guard let title = data["title"] as? String,
              let description = data["description"] as? String,
              let address = data["address"] as? String,
              let price = data["price"] as? Double,
              let landlordID = data["landlordID"] as? String else {
            return nil
        }

        let isListed = data["isListed"] as? Bool ?? true
        let listedDate = (data["listedDate"] as? Timestamp)?.dateValue() ?? Date()
        let imageURLs = data["imageURLs"] as? [String] ?? []
        let bedrooms = data["bedrooms"] as? Int ?? 0
        let bathrooms = data["bathrooms"] as? Int ?? 0
        let amenities = data["amenities"] as? [String] ?? []
        let latitude = data["latitude"] as? Double
        let longitude = data["longitude"] as? Double
        let availabilityDate = (data["availabilityDate"] as? Timestamp)?.dateValue()
        let ratings = data["ratings"] as? Double

        return Property(
            id: document.documentID,
            title: title,
            description: description,
            address: address,
            price: price,
            landlordID: landlordID,
            isListed: isListed,
            listedDate: listedDate,
            imageURLs: imageURLs,
            bedrooms: bedrooms,
            bathrooms: bathrooms,
            amenities: amenities,
            latitude: latitude,
            longitude: longitude,
            availabilityDate: availabilityDate,
            ratings: ratings
        )
    }

    private func propertyToDict(_ property: Property) -> [String: Any] {
        return [
            "id": property.id,
            "title": property.title,
            "description": property.description,
            "address": property.address,
            "price": property.price,
            "landlordID": property.landlordID,
            "isListed": property.isListed,
            "listedDate": property.listedDate,
            "imageURLs": property.imageURLs,
            "bedrooms": property.bedrooms,
            "bathrooms": property.bathrooms,
            "amenities": property.amenities,
            "latitude": property.latitude as Any,
            "longitude": property.longitude as Any,
            "availabilityDate": property.availabilityDate as Any,
            "ratings": property.ratings as Any,
        ]
    }
}
