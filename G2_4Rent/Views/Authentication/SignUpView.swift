import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole: UserRole = .tenant
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white.opacity(0.9)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()

                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    TextField("Full Name", text: $name)
                        .autocapitalization(.words)
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    SecureField("Password", text: $password)
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

                Picker("Role", selection: $selectedRole) {
                    Text("Tenant").tag(UserRole.tenant)
                    Text("Landlord").tag(UserRole.landlord)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

                Button(action: {
                    signUp()
                }) {
                    Text("Register")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.green.opacity(0.4), radius: 10, x: 0, y: 10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Sign Up"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertMessage == "Registration successful!" {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }

    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = "Error: \(error.localizedDescription)"
                showAlert = true
                return
            }

            guard let userID = result?.user.uid else { return }
            let user = User(id: userID, name: name, email: email, role: selectedRole)

            let db = Firestore.firestore()
            db.collection("users").document(userID).setData([
                "id": user.id,
                "name": user.name,
                "email": user.email,
                "role": user.role.rawValue,
            ]) { error in
                if let error = error {
                    alertMessage = "Error saving user: \(error.localizedDescription)"
                } else {
                    alertMessage = "Registration successful!"
                    authViewModel.user = user
                }
                showAlert = true
            }
        }
    }
}

#Preview {
    SignUpView()
}
