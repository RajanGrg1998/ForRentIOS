import FirebaseFirestore
import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var contactInfo: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Edit Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                  
                    Group {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.headline)
                            TextField("Enter your name", text: $name)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                            TextField("Enter your email", text: $email)
                                .keyboardType(.emailAddress)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contact Info")
                                .font(.headline)
                            TextField("Enter your contact info", text: $contactInfo)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    // Save Button
                    Button(action: {
                        saveProfile()
                    }) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 10)
                    }
                    .padding(.horizontal, 30)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Profile Updated"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"), action: {
                                presentationMode.wrappedValue.dismiss()
                            })
                        )
                    }
                }
                .padding(.vertical, 30)
            }
            .navigationTitle("Edit Profile")
            .onAppear {
                loadUserData()
            }
        }
    }

    private func loadUserData() {
        if let user = authViewModel.user {
            name = user.name
            email = user.email
            contactInfo = user.contactInfo ?? ""
        }
    }

    private func saveProfile() {
        guard let userID = authViewModel.user?.id else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userID).updateData([
            "name": name,
            "email": email,
            "contactInfo": contactInfo,
        ]) { error in
            if let error = error {
                alertMessage = "Error updating profile: \(error.localizedDescription)"
            } else {
                authViewModel.user?.name = name
                authViewModel.user?.email = email
                authViewModel.user?.contactInfo = contactInfo
                alertMessage = "Your profile has been updated successfully!"
            }
            showAlert = true
        }
    }
}
