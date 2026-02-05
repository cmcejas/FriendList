import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Vote: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var listId: String
    var userId: String
    var displayName: String
    var choice: String // "over" | "under"
    var votedAt: Date

    init(
        id: String? = nil,
        listId: String,
        userId: String,
        displayName: String,
        choice: String,
        votedAt: Date = Date()
    ) {
        self.id = id
        self.listId = listId
        self.userId = userId
        self.displayName = displayName
        self.choice = choice
        self.votedAt = votedAt
    }

    var isOver: Bool { choice == "over" }
    var isUnder: Bool { choice == "under" }
}
