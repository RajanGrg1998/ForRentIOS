//
//  PropertiesView.swift
//  G2_4Rent
//
//  Created by Rajan Gurungq on 2024-11-08.
//

import SwiftUI

struct PropertiesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var propertyViewModel = PropertyViewModel()
    @State private var showAddPropertyView = false
    @State private var searchText = ""

    var filteredProperties: [Property] {
        let properties = authViewModel.user?.role == .landlord ? propertyViewModel.landlordProperties : propertyViewModel.properties
        return searchText.isEmpty ? properties : properties.filter {
            $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.address.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search properties...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if authViewModel.user?.role == .landlord {
                    List(filteredProperties) { property in
                        NavigationLink(destination: AddPropertyView(property: property)) {
                            PropertyRow(property: property)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                propertyViewModel.deleteProperty(property) { _ in }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onAppear {
                        propertyViewModel.fetchLandlordProperties(landlordID: authViewModel.user?.id ?? "")
                    }

                    Button(action: { showAddPropertyView = true }) {
                        Text("Add New Property")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    .sheet(isPresented: $showAddPropertyView) {
                        AddPropertyView()
                    }
                } else {
                    List(filteredProperties) { property in
                        NavigationLink(destination: PropertyDetailView(property: property)) {
                            PropertyRow(property: property)
                        }
                    }
                    .onAppear {
                        propertyViewModel.fetchAllProperties()
                    }
                }
            }
            .navigationTitle(authViewModel.user?.role == .landlord ? "My Properties" : "Available Properties")
        }
    }
}

struct PropertyRow: View {
    let property: Property

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(property.title)
                    .font(.headline)

                Text("Price: $\(property.price, specifier: "%.2f")")
                    .font(.subheadline)

                Text(property.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
    }
}
