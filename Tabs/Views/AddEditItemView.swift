import SwiftUI

struct AddEditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTitleFocused: Bool

    var editingItem: ListItem?
    let onSave: (String, Int) -> Void

    @State private var title: String = ""
    @State private var count: Int = 0

    private var isEditing: Bool { editingItem != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("What to track", text: $title)
                        .focused($isTitleFocused)
                        .textInputAutocapitalization(.sentences)
                }
                Section("Count") {
                    Stepper("Value: \(count)", value: $count, in: 0...9999)
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let item = editingItem {
                    title = item.title
                    count = item.count
                }
                isTitleFocused = true
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSave(trimmed, count)
        dismiss()
    }
}
