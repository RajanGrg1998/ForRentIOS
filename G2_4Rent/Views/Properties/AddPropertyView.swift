import FirebaseFirestore
import SwiftUI

struct AddPropertyView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var propertyViewModel = PropertyViewModel()

    var property: Property?

    @State private var title = ""
    @State private var description = ""

    @State private var address = ""

    @State private var price: Double = 0.0
    @State private var bedrooms = 1
    @State private var bathrooms = 1
    @State private var amenities: [String] = []
    @State private var newAmenity = ""
    @State private var availabilityDate = Date()
    @State private var imageURLs: [String] = []
    @State private var newImageURL = ""
    @State private var locationChoice = "Use Current Location"

    @State private var latitude: Double?
    @State private var longitude: Double?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Text(isEditMode() ? "Edit Property" : "Add Property")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    propertyDetailsSection()
                    bedroomsBathroomsSection()
                    amenitiesSection()
                    imagesSection()

                    DatePicker("Availability Date", selection: $availabilityDate, displayedComponents: .date)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)

                    Button(action: {
                        if isEditMode() {
                            updateProperty()
                        } else {
                            addProperty()
                        }
                    }) {
                        Text(isEditMode() ? "Update Property" : "Add Property")

                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 10)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .onAppear {
                if let property = property {
                    populateFields(for: property)
                }
            }
        }
    }

    private func propertyDetailsSection() -> some View {
        Group {
            VStack(alignment: .leading, spacing: 10) {
                Text("Property Title")
                    .font(.headline)
                TextField("Enter title", text: $title)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                Text("Description")
                    .font(.headline)
                TextField("Enter description", text: $description)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                Text("Address")
                    .font(.headline)

                Picker("Location Input", selection: $locationChoice) {
                    Text("Use Current Location").tag("Use Current Location")
                    Text("Enter Address").tag("Enter Address")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical)

                if locationChoice == "Enter Address" {
                    TextField("Enter address", text: $address)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Button("Get Location") {
                    if locationChoice == "Use Current Location" {
                        fetchCurrentLocation()
                    } else {
                        geocodeAddress(address)
                    }
                }
                .padding(.vertical)

                if let latitude = latitude, let longitude = longitude {
                    Text("Location: \(latitude), \(longitude)")
                        .padding()
                }

                Text("Price")
                    .font(.headline)
                TextField("Enter price", value: $price, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(UIColor.systemGray6))

                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }

    private func bedroomsBathroomsSection() -> some View {
        VStack(spacing: 20) {
            Stepper("Bedrooms: \(bedrooms)", value: $bedrooms, in: 0 ... 10)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)

            Stepper("Bathrooms: \(bathrooms)", value: $bathrooms, in: 0 ... 10)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    private func amenitiesSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                TextField("Enter amenity", text: $newAmenity)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                Button("Add") {
                    if !newAmenity.isEmpty {
                        amenities.append(newAmenity)
                        newAmenity = ""
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            if !amenities.isEmpty {
                VStack(alignment: .leading) {
                    Text("Amenities:")
                        .font(.headline)
                    ForEach(amenities, id: \.self) { amenity in
                        Text("- \(amenity)")
                            .padding(.leading)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func imagesSection() -> some View {
        VStack {
            HStack {
                TextField("Enter Image URL", text: $newImageURL)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                Button("Add Image") {
                    addImageURL()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(imageURLs, id: \.self) { url in
                        VStack {
                            AsyncImage(url: URL(string: url)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }

                            Button(action: {
                                imageURLs.removeAll { $0 == url }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }

    private func isEditMode() -> Bool {
        return property != nil
    }

    private func populateFields(for property: Property) {
        title = property.title
        description = property.description
        address = property.address
        price = property.price
        bedrooms = property.bedrooms
        bathrooms = property.bathrooms
        amenities = property.amenities
        imageURLs = property.imageURLs
        availabilityDate = property.availabilityDate ?? Date()
    }

    private func addImageURL() {
        if !newImageURL.isEmpty, !imageURLs.contains(newImageURL) {
            imageURLs.append(newImageURL)
            newImageURL = ""
        }
    }

    private func addProperty() {
        guard let landlordID = authViewModel.user?.id else { return }
        let newProperty = Property(
            id: UUID().uuidString,
            title: title,
            description: description,
            address: address,
            price: price,
            landlordID: landlordID,
            isListed: true,
            imageURLs: imageURLs,
            bedrooms: bedrooms,
            bathrooms: bathrooms,
            amenities: amenities,
            latitude: latitude,
            longitude: longitude,
            availabilityDate: availabilityDate
        )
        propertyViewModel.addProperty(newProperty) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private func updateProperty() {
        guard var property = property else { return }
        property.title = title
        property.description = description
        property.address = address
        property.price = price
        property.imageURLs = imageURLs
        property.bedrooms = bedrooms
        property.bathrooms = bathrooms
        property.amenities = amenities
        property.latitude = latitude
        property.longitude = longitude
        property.availabilityDate = availabilityDate

        propertyViewModel.updateProperty(property) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private func fetchCurrentLocation() {
        LocationManager.shared.fetchCurrentLocation { location in
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }

    private func geocodeAddress(_ address: String) {
        LocationManager.shared.performForwardGeocoding(address: address) { location in
            if let location = location {
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
            } else {
                print("Failed to geocode address.")
            }
        }
    }
}
