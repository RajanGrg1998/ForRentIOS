import FirebaseFirestore
import MapKit
import SwiftUI

struct PropertyDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var requestViewModel = RequestViewModel()

    let property: Property
    @State private var region = MKCoordinateRegion()
    @State private var showLoginPrompt = false
    @State private var requestSent = false
    @State private var showShareSheet = false
    @State private var shareContent: String = ""
    @State private var hasRequested = false
    @State private var requestStatus: RequestStatus?
    @State private var isInShortlist: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(property.imageURLs, id: \.self) { photo in
                            AsyncImage(url: URL(string: photo)) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipped()
                            } placeholder: {
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 250)
                                    .foregroundColor(.gray)
                                    .background(Color.gray.opacity(0.2))
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(property.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Price: $\(String(format: "%.2f", property.price))")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .padding(.horizontal)

                Section(header: Text("Description").font(.headline)) {
                    Text(property.description)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    propertyDetailRow(title: "Bedrooms", value: "\(property.bedrooms)")
                    propertyDetailRow(title: "Bathrooms", value: "\(property.bathrooms)")

                    if let date = property.availabilityDate {
                        propertyDetailRow(title: "Available From", value: formattedDate(date))
                    }

                    if let latitude = property.latitude, let longitude = property.longitude {
                        propertyDetailRow(title: "Location", value: "Lat: \(latitude), Long: \(longitude)")
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

                // Amenities Section
                if !property.amenities.isEmpty {
                    Section(header: Text("Amenities").font(.headline)) {
                        ForEach(property.amenities, id: \.self) { amenity in
                            Text("- \(amenity)")
                                .padding(.vertical, 2)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                VStack(spacing: 20) {
                    if let latitude = property.latitude, let longitude = property.longitude {
                        NavigationLink(destination: MapView(coordinate: CLLocationCoordinate2D(
                                latitude: latitude,
                                longitude: longitude),
                            title: property.title)
                        ) {
                            Text("Show on Map")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    } else {
                        Text("Location not available")
                    }
                    Button(action: handleRequestAction) {
                        Text(requestStatusText())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(requestButtonColor())
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(hasRequested || !authViewModel.isAuthenticated)

                    Button(action: shareProperty) {
                        Text("Share Property")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }.sheet(isPresented: $showShareSheet) {
                        ActivityView(activityItems: [shareContent])
                    }

                    if authViewModel.isAuthenticated, authViewModel.user?.role == .tenant {
                        Button(action: toggleShortlist) {
                            Text(isInShortlist ? "Remove from Shortlist" : "Add to Shortlist")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(UIColor.systemGray5))
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }

            .padding(.vertical)
        }
        .navigationTitle("Property Details")
        .onAppear {
            checkIfInShortlist()
        }
    }

    private func propertyDetailRow(title: String, value: String) -> some View {
        HStack {
            Text("\(title):")
                .fontWeight(.bold)
            Spacer()
            Text(value)
        }
        .padding(.vertical, 5)
    }

    private func setRegion(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func requestStatusText() -> String {
        if let status = requestStatus {
            switch status {
            case .pending: return "Request Pending"
            case .approved: return "Request Approved"
            case .denied: return "Request Denied"
            }
        }
        return "Request Property"
    }

    private func requestButtonColor() -> Color {
        switch requestStatus {
        case .approved: return Color.green
        case .denied: return Color.red
        case .pending: return Color.orange
        default: return authViewModel.isAuthenticated ? Color.blue : Color.gray
        }
    }

    private func handleRequestAction() {
        if authViewModel.isAuthenticated {
            sendPropertyRequest()
        } else {
            showLoginPrompt = true
        }
    }

    private func sendPropertyRequest() {
        guard let user = authViewModel.user else { return }
        let requestID = UUID().uuidString
        let requestData: [String: Any] = [
            "id": requestID,
            "propertyID": property.id,
            "requesterID": user.id,
            "landlordID": property.landlordID,
            "status": RequestStatus.pending.rawValue,
            "requestDate": Timestamp(date: Date()),
        ]
        Firestore.firestore().collection("requests").document(requestID).setData(requestData) { error in
            if error == nil {
                hasRequested = true
                requestStatus = .pending
            }
        }
    }

    private func toggleShortlist() {
        guard let user = authViewModel.user else { return }
        if isInShortlist {
            authViewModel.removeFromShortlist(propertyID: property.id) { success in
                if success { isInShortlist = false }
            }
        } else {
            authViewModel.addToShortlist(propertyID: property.id) { success in
                if success { isInShortlist = true }
            }
        }
    }

    private func checkIfInShortlist() {
        isInShortlist = authViewModel.isPropertyInShortlist(propertyID: property.id)
    }

    private func shareProperty() {
        shareContent = """
        Check out this property!
        Title: \(property.title)
        Address: \(property.address)
        Description: \(property.description)
        Price: $\(String(format: "%.2f", property.price))
        Bedrooms: \(property.bedrooms)
        Bathrooms: \(property.bathrooms)
        Amenities: \(property.amenities.joined(separator: ", "))
        Available From: \(formattedDate(property.availabilityDate ?? Date()))
        """
        showShareSheet = true
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// map
struct MapView: View {
    var coordinate: CLLocationCoordinate2D
    var title: String

    @State private var region: MKCoordinateRegion

    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [MapMarkerItem(coordinate: coordinate, title: title)]) { marker in
            MapMarker(coordinate: marker.coordinate, tint: .blue)
        }
        .navigationTitle("Property Location")
    }
}

struct MapMarkerItem: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    var title: String
}
