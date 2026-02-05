import SwiftUI

struct BetListRowView: View {
    let list: BetList
    let voteCount: Int

    private var isClosed: Bool { list.isClosed }

    private var locked: Bool { list.locked }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 4) {
                    Text(list.title)
                        .font(.headline)
                    if locked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if isClosed {
                    Text("Ended")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(list.timeLeft)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                Text("Line: \(list.bettingLine, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("·")
                    .foregroundStyle(.secondary)
                Text("\(voteCount) vote\(voteCount == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
