import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct BetList: Identifiable, Codable, Equatable, Hashable {
    @DocumentID var id: String?
    var title: String
    var createdBy: String
    var createdByName: String
    var createdAt: Date
    var expiresAt: Date
    var bettingLine: Double
    var status: String // "open" | "closed"
    var isLocked: Bool? // nil = false for older docs

    init(
        id: String? = nil,
        title: String,
        createdBy: String,
        createdByName: String,
        createdAt: Date = Date(),
        expiresAt: Date,
        bettingLine: Double,
        status: String = "open",
        isLocked: Bool? = false
    ) {
        self.id = id
        self.title = title
        self.createdBy = createdBy
        self.createdByName = createdByName
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.bettingLine = bettingLine
        self.status = status
        self.isLocked = isLocked
    }

    var isClosed: Bool {
        status == "closed" || expiresAt <= Date()
    }

    var locked: Bool { isLocked ?? false }

    /// Editable (voting) only in the first 30% of the time from creation to expiry.
    var isWithinEditableWindow: Bool {
        let total = expiresAt.timeIntervalSince(createdAt)
        guard total > 0 else { return false }
        let cutoff = createdAt.addingTimeInterval(0.3 * total)
        return Date() < cutoff
    }

    var canVoteOrChangeVote: Bool {
        !isClosed && !locked && isWithinEditableWindow
    }

    var expiresAtFormatted: String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: expiresAt)
    }

    var timeLeft: String {
        guard expiresAt > Date() else { return "Ended" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: expiresAt, relativeTo: Date())
    }
}
