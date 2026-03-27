import FirebaseAuth
import FirebaseFirestore
import Foundation

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var email = ""
    @Published var password = ""
    @Published var rememberMe = false
    @Published var showLoginView = false

    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()

    init() {
        if let firebaseUser = Auth.auth().currentUser {
            fetchUserData(for: firebaseUser.uid)
        }

        if let savedEmail = defaults.string(forKey: "email"),
           let savedPassword = defaults.string(forKey: "password") {
            email = savedEmail
            password = savedPassword
            rememberMe = true
        }
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            }

            guard let firebaseUser = result?.user else { return }
            self.fetchUserData(for: firebaseUser.uid)

            if self.rememberMe {
                self.saveCredentials()
            } else {
                self.clearCredentials()
            }
        }
    }

    private func fetchUserData(for userID: String) {
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let data = document?.data(),
                  let name = data["name"] as? String,
                  let email = data["email"] as? String,
                  let roleString = data["role"] as? String,
                  let role = UserRole(rawValue: roleString) else {
                print("Error parsing user data")
                return
            }

            let contactInfo = data["contactInfo"] as? String
            let shortlistData = data["shortlist"] as? [String] ?? []

            DispatchQueue.main.async {
                self.user = User(
                    id: userID,
                    name: name,
                    email: email,
                    contactInfo: contactInfo,
                    role: role,
                    shortlist: shortlistData
                )
                self.isAuthenticated = true
            }
        }
    }

    func addToShortlist(propertyID: String, completion: @escaping (Bool) -> Void) {
        guard let user = user else { return }

        if user.shortlist.contains(propertyID) {
            completion(false)
            return
        }

        var updatedShortlist = user.shortlist
        updatedShortlist.append(propertyID)

        db.collection("users").document(user.id).updateData([
            "shortlist": updatedShortlist,
        ]) { error in
            if let error = error {
                print("Error adding to shortlist: \(error.localizedDescription)")
                completion(false)
            } else {
                DispatchQueue.main.async {
                    self.user?.shortlist = updatedShortlist
                }
                completion(true)
            }
        }
    }

    func removeFromShortlist(propertyID: String, completion: @escaping (Bool) -> Void) {
        guard let user = user else { return }

        let updatedShortlist = user.shortlist.filter { $0 != propertyID }

        db.collection("users").document(user.id).updateData([
            "shortlist": updatedShortlist,
        ]) { error in
            if let error = error {
                print("Error removing from shortlist: \(error.localizedDescription)")
                completion(false)
            } else {
                DispatchQueue.main.async {
                    self.user?.shortlist = updatedShortlist
                }
                completion(true)
            }
        }
    }

    func isPropertyInShortlist(propertyID: String) -> Bool {
        return user?.shortlist.contains(propertyID) ?? false
    }

    func updateShortlist(with newShortlist: [String], completion: @escaping (Bool) -> Void) {
        guard let user = user else { return }

        db.collection("users").document(user.id).updateData([
            "shortlist": newShortlist,
        ]) { error in
            if let error = error {
                print("Error updating shortlist: \(error.localizedDescription)")
                completion(false)
            } else {
                DispatchQueue.main.async {
                    self.user?.shortlist = newShortlist
                }
                completion(true)
            }
        }
    }

    func saveCredentials() {
        defaults.set(email, forKey: "email")
        defaults.set(password, forKey: "password")
        defaults.set(true, forKey: "rememberMe")
    }

    func loadCredentials() {
        if defaults.bool(forKey: "rememberMe") {
            if let savedEmail = defaults.string(forKey: "email"),
               let savedPassword = defaults.string(forKey: "password") {
                email = savedEmail
                password = savedPassword
                rememberMe = true
            }
        }
    }

    func clearCredentials() {
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "password")
        defaults.set(false, forKey: "rememberMe")
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            user = nil
            isAuthenticated = false
            clearCredentials()
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
}
