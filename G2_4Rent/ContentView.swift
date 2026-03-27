//
//  ContentView.swift
//  G2_4Rent
//
//  Created by Rajan Gurungq on 2024-11-08.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            PropertiesView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Properties")
                }

            if authViewModel.isAuthenticated {
                RequestsView()
                    .tabItem {
                        Image(systemName: "envelope.fill")
                        Text("Requests")
                    }
            }

            if authViewModel.isAuthenticated, authViewModel.user?.role == .tenant {
                ShortlistView()
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Shortlist")
                    }
            }

            if authViewModel.isAuthenticated {
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
            } else {
                AuthenticationPromptView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
            }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}

struct AuthenticationPromptView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
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
                .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 10)
            }
            .padding(.horizontal, 50)
        }
        .padding()

        .padding()

        .sheet(isPresented: $authViewModel.showLoginView) {
            LoginView()
        }
    }
}
