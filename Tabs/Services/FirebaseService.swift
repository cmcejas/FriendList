import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

@MainActor
final class FirebaseService: ObservableObject {
    static let shared = FirebaseService()

    private let collection = Firestore.firestore().collection("items")
    private var listener: ListenerRegistration?

    @Published var items: [ListItem] = []
    @Published var errorMessage: String?

    private init() {}

    func startListening() {
        listener = collection
            .order(by: "lastEdited", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    self?.errorMessage = nil
                    self?.items = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: ListItem.self)
                    } ?? []
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func addItem(title: String, count: Int = 0) async {
        let item = ListItem(title: title, count: count, lastEdited: Date())
        do {
            try collection.addDocument(from: item)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateItem(_ item: ListItem) async {
        guard let id = item.id else { return }
        let updated = ListItem(
            id: id,
            title: item.title,
            count: item.count,
            lastEdited: Date()
        )
        do {
            try collection.document(id).setData(from: updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func incrementCount(for item: ListItem) async {
        var updated = item
        updated.count += 1
        updated.lastEdited = Date()
        await updateItem(updated)
    }

    func decrementCount(for item: ListItem) async {
        var updated = item
        updated.count = max(0, item.count - 1)
        updated.lastEdited = Date()
        await updateItem(updated)
    }

    func deleteItem(_ item: ListItem) async {
        guard let id = item.id else { return }
        do {
            try await collection.document(id).delete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
