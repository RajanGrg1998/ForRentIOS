

import FirebaseAuth
import FirebaseFirestore
import Foundation

class RequestViewModel: ObservableObject {
    @Published var requests: [Request] = []
    private var db = Firestore.firestore()

    func fetchRequests(for landlordID: String) {
        db.collection("requests")
            .whereField("landlordID", isEqualTo: landlordID)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching requests: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self?.requests = []
                    }
                    return
                }

                self?.requests = documents.compactMap { document -> Request? in
                    let data = document.data()
                    let requestID = document.documentID
                    let requesterID = data["requesterID"] as? String ?? ""
                    let propertyID = data["propertyID"] as? String ?? ""
                    let landlordID = data["landlordID"] as? String ?? ""
                    let statusString = data["status"] as? String ?? RequestStatus.pending.rawValue
                    let status = RequestStatus(rawValue: statusString) ?? .pending
                    let requestDate = (data["requestDate"] as? Timestamp)?.dateValue() ?? Date()
                    let responseDate = (data["responseDate"] as? Timestamp)?.dateValue()
                    let message = data["message"] as? String

                    return Request(
                        id: requestID,
                        requesterID: requesterID,
                        propertyID: propertyID,
                        landlordID: landlordID,
                        status: status,
                        requestDate: requestDate,
                        responseDate: responseDate,
                        message: message
                    )
                }
            }
    }

    func fetchTenantRequests(for tenantID: String) {
        db.collection("requests")
            .whereField("requesterID", isEqualTo: tenantID)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching tenant requests: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self?.requests = []
                    }
                    return
                }

                self?.requests = documents.compactMap { document -> Request? in
                    let data = document.data()
                    let requestID = document.documentID
                    let requesterID = data["requesterID"] as? String ?? ""
                    let propertyID = data["propertyID"] as? String ?? ""
                    let landlordID = data["landlordID"] as? String ?? ""
                    let statusString = data["status"] as? String ?? RequestStatus.pending.rawValue
                    let status = RequestStatus(rawValue: statusString) ?? .pending
                    let requestDate = (data["requestDate"] as? Timestamp)?.dateValue() ?? Date()
                    let responseDate = (data["responseDate"] as? Timestamp)?.dateValue()
                    let message = data["message"] as? String

                    return Request(
                        id: requestID,
                        requesterID: requesterID,
                        propertyID: propertyID,
                        landlordID: landlordID,
                        status: status,
                        requestDate: requestDate,
                        responseDate: responseDate,
                        message: message
                    )
                }
            }
    }

    func updateRequestStatus(request: Request, status: RequestStatus, completion: @escaping (Bool) -> Void) {
        db.collection("requests").document(request.id).updateData([
            "status": status.rawValue,
            "responseDate": Date(),
        ]) { error in
            if let error = error {
                print("Error updating request status: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func getProperty(by id: String) -> Property? {
        return nil
    }

    func getUser(by id: String) -> User? {
        return nil
    }
}
