import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

@MainActor
final class VoteService: ObservableObject {
    static let shared = VoteService()

    private let store = Firestore.firestore()
    private var voteListeners: [String: ListenerRegistration] = [:]

    @Published var votes: [String: [Vote]] = [:] // listId -> votes
    @Published var errorMessage: String?

    private init() {}

    func votesCollection(listId: String) -> CollectionReference {
        store.collection("lists").document(listId).collection("votes")
    }

    func startListeningVotes(listId: String) {
        guard voteListeners[listId] == nil else { return }
        voteListeners[listId] = votesCollection(listId: listId)
            .order(by: "votedAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    self?.errorMessage = nil
                    let listVotes = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Vote.self)
                    } ?? []
                    self?.votes[listId] = listVotes
                }
            }
    }

    func stopListeningVotes(listId: String) {
        voteListeners[listId]?.remove()
        voteListeners[listId] = nil
        votes[listId] = nil
    }

    func vote(listId: String, userId: String, displayName: String, choice: String) async {
        let vote = Vote(
            listId: listId,
            userId: userId,
            displayName: displayName,
            choice: choice,
            votedAt: Date()
        )
        let col = votesCollection(listId: listId)
        do {
            let existing = try await col.whereField("userId", isEqualTo: userId).getDocuments()
            if let doc = existing.documents.first {
                try doc.reference.setData(from: vote)
            } else {
                try col.addDocument(from: vote)
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func myVote(listId: String, userId: String) -> Vote? {
        votes[listId]?.first { $0.userId == userId }
    }

    func votesForList(_ listId: String) -> [Vote] {
        votes[listId] ?? []
    }

    func overVotes(listId: String) -> [Vote] {
        votesForList(listId).filter { $0.isOver }
    }

    func underVotes(listId: String) -> [Vote] {
        votesForList(listId).filter { $0.isUnder }
    }
}
