//
//  RequestsView.swift
//  G2_4Rent
//
//  Created by Rajan Gurung on 2024-11-08.
//

import SwiftUI

struct RequestsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var requestViewModel = RequestViewModel()
    @State private var showDeleteConfirmation = false
    @State private var selectedRequest: Request?

    var body: some View {
        NavigationView {
            VStack {
                if requestViewModel.requests.isEmpty {
                    Text("No requests found.")
                        .font(.headline)
                        .padding()
                } else {
                    List(requestViewModel.requests) { request in
                        NavigationLink(destination: RequestDetailView(request: request)) {
                            HStack {
                                Text("Request from: \(request.requesterID)")
                                Spacer()
                                Text(request.status.rawValue.capitalized)
                                    .foregroundColor(request.status == .approved ? .green : (request.status == .denied ? .red : .orange))
                            }
                        }
                        .swipeActions {
                            if authViewModel.user?.role == .landlord {
                                if request.status == .pending {
                                    Button("Approve") {
                                        approveRequest(request)
                                    }
                                    .tint(.green)

                                    Button("Deny") {
                                        selectedRequest = request
                                        showDeleteConfirmation = true
                                    }
                                    .tint(.red)
                                }
                            }
                        }
                    }
                    .onAppear {
                        fetchRequests()
                    }
                    .navigationTitle("Requests")
                    .confirmationDialog(
                        "Are you sure you want to deny this request?",
                        isPresented: $showDeleteConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Deny", role: .destructive) {
                            if let requestToDeny = selectedRequest {
                                denyRequest(requestToDeny)
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                }
            }
        }
        .onAppear {
            fetchRequests()
        }
    }

    private func approveRequest(_ request: Request) {
        requestViewModel.updateRequestStatus(request: request, status: .approved) { success in
            if success {
                refreshRequests()
            }
        }
    }

    private func denyRequest(_ request: Request) {
        requestViewModel.updateRequestStatus(request: request, status: .denied) { success in
            if success {
                refreshRequests()
            }
        }
    }

    private func fetchRequests() {
        if authViewModel.user?.role == .landlord {
            requestViewModel.fetchRequests(for: authViewModel.user?.id ?? "")
        } else {
            requestViewModel.fetchTenantRequests(for: authViewModel.user?.id ?? "")
        }
    }

    private func refreshRequests() {
        fetchRequests()
    }
}

#Preview {
    RequestsView()
        .environmentObject(AuthViewModel())
}
