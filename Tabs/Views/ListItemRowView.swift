import SwiftUI

struct ListItemRowView: View {
    let item: ListItem
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isEditing = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(item.lastEditedFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                onEdit()
            }

            HStack(spacing: 8) {
                Button {
                    onDecrement()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)

                Text("\(item.count)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(minWidth: 36, alignment: .center)

                Button {
                    onIncrement()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
