import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: User?
    @Published var displayName: String = ""
    @Published var errorMessage: String?

    private let usersCollection = Firestore.firestore().collection("users")

    private init() {
        currentUser = Auth.auth().currentUser
        if let uid = currentUser?.uid {
            Task { await loadDisplayName(uid: uid) }
        }
        listenAuth()
    }

    private func listenAuth() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                if let uid = user?.uid {
                    await self?.loadDisplayName(uid: uid)
                } else {
                    self?.displayName = ""
                }
            }
        }
    }

    func loadDisplayName(uid: String) async {
        do {
            let doc = try await usersCollection.document(uid).getDocument()
            displayName = doc.data()?["displayName"] as? String ?? ""
        } catch {
            displayName = ""
        }
    }

    func signInAnonymously() async {
        do {
            _ = try await Auth.auth().signInAnonymously()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setDisplayName(_ name: String) async {
        guard let uid = currentUser?.uid else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            try usersCollection.document(uid).setData(["displayName": trimmed], merge: true)
            displayName = trimmed
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        displayName = ""
    }

    var isSignedIn: Bool { currentUser != nil }
    var hasDisplayName: Bool { !displayName.isEmpty }
}
