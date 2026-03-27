//
//  G2_4RentApp.swift
//  G2_4Rent
//
//  Created by Rajan Gurungq on 2024-11-08.
//

import Firebase
import SwiftUI

@main
struct G2_4RentApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var requestViewModel = RequestViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(requestViewModel)
        }
    }
}
