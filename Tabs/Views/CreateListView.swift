import SwiftUI

struct CreateListView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTitleFocused: Bool

    let onCreate: (String, Date, Double) -> Void

    @State private var title = ""
    @State private var expiresAt = Date().addingTimeInterval(86400) // 1 day
    @State private var bettingLineText = "0"

    private var lineValue: Double {
        Double(bettingLineText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Bet title") {
                    TextField("e.g. Points scored", text: $title)
                        .focused($isTitleFocused)
                        .textInputAutocapitalization(.sentences)
                }
                Section("Expires") {
                    DatePicker("Closes at", selection: $expiresAt, in: Date()...)
                        .datePickerStyle(.compact)
                }
                Section("Betting line") {
                    TextField("Line (number)", text: $bettingLineText)
                        .keyboardType(.decimalPad)
                    Text("Everyone picks Over or Under this number.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New bet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onCreate(trimmed, expiresAt, lineValue)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear { isTitleFocused = true }
        }
    }
}
