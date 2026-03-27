import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditingProfile = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white.opacity(0.9)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                if authViewModel.isAuthenticated {
                    if let user = authViewModel.user {
                        VStack(spacing: 10) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .padding()

                            Text("Welcome, \(user.name)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            Text("Email: \(user.email)")
                                .font(.body)
                                .foregroundColor(.gray)

                            Text("Role: \(user.role.rawValue.capitalized)")
                                .font(.body)
                                .foregroundColor(.gray)

                            if let contactInfo = user.contactInfo {
                                Text("Contact Info: \(contactInfo)")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .padding(.top, 10)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .padding()

                        Spacer()

                        Button(action: {
                            isEditingProfile.toggle()
                        }) {
                            Text("Edit Profile")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 10)
                        }
                        .padding(.horizontal)
                        .sheet(isPresented: $isEditingProfile) {
                            EditProfileView()
                        }

                        Button(action: {
                            authViewModel.logout()
                        }) {
                            Text("Logout")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: Color.red.opacity(0.4), radius: 10, x: 0, y: 10)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    VStack(spacing: 30) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .padding(.bottom, 10)

                        Text("You are not logged in")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        Text("Log in to access your profile and manage your account.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Button(action: {
                            authViewModel.showLoginView = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                Text("Log In")
                                    .font(.headline)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]),
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: Color.green.opacity(0.4), radius: 10, x: 0, y: 10)
                        }
                        .padding(.horizontal, 50)
                        .sheet(isPresented: $authViewModel.showLoginView) {
                            LoginView()
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
