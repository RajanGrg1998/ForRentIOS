import SwiftUI

struct ShortlistView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var propertyViewModel = PropertyViewModel()

    @State private var showRemoveConfirmation = false
    @State private var selectedPropertyIDs: Set<String> = []
    @State private var showRemoveAllConfirmation = false
    @State private var isSelectionModeActive = false

    var body: some View {
        NavigationView {
            VStack {
                if authViewModel.user?.shortlist.isEmpty ?? true {
                    Text("Your shortlist is empty.")
                        .font(.headline)
                        .padding()
                } else {
                    List {
                        ForEach(authViewModel.user?.shortlist ?? [], id: \.self) { propertyID in
                            if let property = propertyViewModel.properties.first(where: { $0.id == propertyID }) {
                                HStack {
                                    if isSelectionModeActive {
                                        Button(action: {
                                            if selectedPropertyIDs.contains(propertyID) {
                                                selectedPropertyIDs.remove(propertyID)
                                            } else {
                                                selectedPropertyIDs.insert(propertyID)
                                            }
                                        }) {
                                            Image(systemName: selectedPropertyIDs.contains(propertyID) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedPropertyIDs.contains(propertyID) ? .blue : .gray)
                                        }
                                    }

                                    if !isSelectionModeActive {
                                        NavigationLink(destination: PropertyDetailView(property: property)) {
                                            PropertyRow(property: property)
                                        }
                                    } else {
                                        PropertyRow(property: property)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                if selectedPropertyIDs.contains(propertyID) {
                                                    selectedPropertyIDs.remove(propertyID)
                                                } else {
                                                    selectedPropertyIDs.insert(propertyID)
                                                }
                                            }
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        selectedPropertyIDs.insert(propertyID)
                                        showRemoveConfirmation = true
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                Button(action: {
                    isSelectionModeActive.toggle()
                    selectedPropertyIDs.removeAll()
                }) {
                    Text(isSelectionModeActive ? "Done Selecting" : "Select Properties")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                if !selectedPropertyIDs.isEmpty {
                    Button(action: {
                        showRemoveAllConfirmation = true
                    }) {
                        Text("Remove Selected")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .navigationTitle("Shortlist")
            .alert(isPresented: $showRemoveConfirmation) {
                Alert(
                    title: Text("Remove from Shortlist"),
                    message: Text("Are you sure you want to remove this property from your shortlist?"),
                    primaryButton: .destructive(Text("Remove")) {
                        if let propertyID = selectedPropertyIDs.first {
                            removeSingleProperty(propertyID: propertyID)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showRemoveAllConfirmation) {
                Alert(
                    title: Text("Remove Selected Properties"),
                    message: Text("Are you sure you want to remove all selected properties from your shortlist?"),
                    primaryButton: .destructive(Text("Remove All")) {
                        removeAllSelectedProperties()
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                fetchShortlistedProperties()
            }
        }
    }

    private func fetchShortlistedProperties() {
        guard let shortlistIDs = authViewModel.user?.shortlist else { return }
        propertyViewModel.fetchPropertiesByIDs(shortlistIDs) { fetchedProperties in
            DispatchQueue.main.async {
                self.propertyViewModel.properties = fetchedProperties
            }
        }
    }

    private func removeSingleProperty(propertyID: String) {
        authViewModel.removeFromShortlist(propertyID: propertyID) { success in
            if success {
                selectedPropertyIDs.remove(propertyID)
                fetchShortlistedProperties()
            }
        }
    }

    private func removeAllSelectedProperties() {
        guard !selectedPropertyIDs.isEmpty else { return }

        let propertiesToRemove = Array(selectedPropertyIDs)

        removePropertiesSequentially(propertiesToRemove) {
            self.selectedPropertyIDs.removeAll()
            self.fetchShortlistedProperties()
        }
    }

    private func removePropertiesSequentially(_ properties: [String], completion: @escaping () -> Void) {
        guard !properties.isEmpty else {
            completion()
            return
        }

        var propertiesToRemove = properties
        let propertyID = propertiesToRemove.removeFirst()

        authViewModel.removeFromShortlist(propertyID: propertyID) { success in
            if success {
                print("Removed property \(propertyID) from shortlist.")
            } else {
                print("Failed to remove property \(propertyID) from shortlist.")
            }

            self.removePropertiesSequentially(propertiesToRemove, completion: completion)
        }
    }
}
