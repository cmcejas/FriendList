import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

@MainActor
final class ListService: ObservableObject {
    static let shared = ListService()

    private let listsCollection = Firestore.firestore().collection("lists")
    private var listListener: ListenerRegistration?

    @Published var lists: [BetList] = []
    @Published var errorMessage: String?

    private init() {}

    func startListening() {
        listListener = listsCollection
            .order(by: "expiresAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    self?.errorMessage = nil
                    self?.lists = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: BetList.self)
                    } ?? []
                }
            }
    }

    func stopListening() {
        listListener?.remove()
        listListener = nil
    }

    func createList(title: String, expiresAt: Date, bettingLine: Double, createdBy: String, createdByName: String) async {
        let list = BetList(
            title: title,
            createdBy: createdBy,
            createdByName: createdByName,
            expiresAt: expiresAt,
            bettingLine: bettingLine,
            status: "open"
        )
        do {
            try listsCollection.addDocument(from: list)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func closeListIfExpired(_ list: BetList) async {
        guard list.expiresAt <= Date(), list.status == "open", let id = list.id else { return }
        do {
            try await listsCollection.document(id).updateData(["status": "closed"])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteList(_ list: BetList) async {
        guard let id = list.id else { return }
        do {
            let votes = try await listsCollection.document(id).collection("votes").getDocuments()
            for doc in votes.documents {
                try await doc.reference.delete()
            }
            try await listsCollection.document(id).delete()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleLock(_ list: BetList, byUserId userId: String) async {
        guard list.createdBy == userId, let id = list.id else { return }
        do {
            try await listsCollection.document(id).updateData(["isLocked": !list.locked])
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
