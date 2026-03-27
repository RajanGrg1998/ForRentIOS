import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignUp = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white.opacity(0.9)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text("Log in to continue")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                    TextField("Email", text: $authViewModel.email)
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
                    SecureField("Password", text: $authViewModel.password)
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)

                HStack {
                    Button(action: {
                        authViewModel.rememberMe.toggle()
                        if authViewModel.rememberMe {
                            authViewModel.saveCredentials()
                        } else {
                            authViewModel.clearCredentials()
                        }
                    }) {
                        HStack {
                            Image(systemName: authViewModel.rememberMe ? "checkmark.square.fill" : "square")
                                .foregroundColor(authViewModel.rememberMe ? .blue : .gray)
                            Text("Remember Me")
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)

                Button(action: {
                    authViewModel.login()
                }) {
                    Text("Log In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 10)
                }
                .padding(.horizontal)

                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    Button(action: {
                        showSignUp.toggle()
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
                .padding(.top, 10)
            }
            .padding()
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
        .onAppear {
            authViewModel.loadCredentials()
        }
    }
}
