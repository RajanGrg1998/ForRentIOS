import FirebaseFirestore
import SwiftUI

struct RequestDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var requestViewModel = RequestViewModel()

    let request: Request

    @State private var property: Property?
    @State private var requester: User?
    @State private var loading = true
    @State private var errorMessage: String?
    @State private var showApprovalAlert = false
    @State private var approvalStatus: RequestStatus?

    var body: some View {
        NavigationView {
            VStack {
                if loading {
                    ProgressView("Loading...")
                } else {
                    if let property = property, let requester = requester {
                        Text("Request ID: \(request.id)")
                            .font(.title)
                            .padding()

                        Text("Requester: \(requester.name)")
                            .font(.headline)
                            .padding()

                        Text("Property Title: \(property.title)")
                            .font(.headline)
                            .padding()

                        Text("Description: \(property.description)")
                            .padding()

                        Text("Address: \(property.address)")
                            .padding()

                        Text("Price: \(String(format: "%.2f", property.price))")
                            .padding()

                        Text("Request Status: \(request.status.rawValue.capitalized)")
                            .padding()

                        if authViewModel.user?.role == .landlord {
                            HStack {
                                Button(action: {
                                    approvalStatus = .approved
                                    showApprovalAlert = true
                                }) {
                                    Text("Approve Request")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }

                                Button(action: {
                                    approvalStatus = .denied
                                    showApprovalAlert = true
                                }) {
                                    Text("Deny Request")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                        }
                    } else {
                        Text(errorMessage ?? "Unable to load property or requester details.")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
            .navigationTitle("Request Details")
            .onAppear {
                fetchPropertyAndRequesterDetails()
            }
            .alert(isPresented: $showApprovalAlert) {
                Alert(
                    title: Text("Confirm Action"),
                    message: Text("Are you sure you want to \(approvalStatus == .approved ? "approve" : "deny") this request?"),
                    primaryButton: .destructive(Text("Confirm")) {
                        if let status = approvalStatus {
                            updateRequestStatus(to: status)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func fetchPropertyAndRequesterDetails() {
        let db = Firestore.firestore()

        // Fetch property details
        db.collection("properties").document(request.propertyID).getDocument { document, error in
            if let error = error {
                print("Error fetching property: \(error.localizedDescription)")
                self.errorMessage = "Error fetching property details."
                loading = false
                return
            }
            if let document = document, document.exists {
                do {
                    self.property = try document.data(as: Property.self)
                } catch {
                    self.errorMessage = "Error decoding property."
                }
            } else {
                self.errorMessage = "Property does not exist."
            }

            checkLoadingState()
        }

        db.collection("users").document(request.requesterID).getDocument { document, error in
            if let error = error {
                print("Error fetching requester: \(error.localizedDescription)")
                self.errorMessage = "Error fetching requester details."
                loading = false
                return
            }
            if let document = document, document.exists {
                do {
                    self.requester = try document.data(as: User.self)
                } catch {
                    self.errorMessage = "Error decoding requester."
                }
            } else {
                self.errorMessage = "Requester does not exist."
            }

            checkLoadingState()
        }
    }

    private func checkLoadingState() {
        if property != nil && requester != nil {
            loading = false
        }
    }

    private func updateRequestStatus(to status: RequestStatus) {
        requestViewModel.updateRequestStatus(request: request, status: status) { success in
            if success {
                print("Request \(status.rawValue) successfully.")

                fetchPropertyAndRequesterDetails()
            } else {
                print("Failed to update request status.")
            }
        }
    }
}
