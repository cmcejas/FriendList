import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ListItem: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var title: String
    var count: Int
    var lastEdited: Date

    init(id: String? = nil, title: String, count: Int = 0, lastEdited: Date = Date()) {
        self.id = id
        self.title = title
        self.count = count
        self.lastEdited = lastEdited
    }

    var lastEditedFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastEdited, relativeTo: Date())
    }
}
