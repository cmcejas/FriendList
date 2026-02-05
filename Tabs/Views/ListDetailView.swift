import SwiftUI

struct ListDetailView: View {
    let list: BetList
    let currentUserId: String
    let currentUserName: String
    let onCloseIfExpired: () -> Void
    let onDelete: () -> Void

    @StateObject private var voteService = VoteService.shared
    @StateObject private var listService = ListService.shared
    @State private var showDeleteConfirm = false

    private var displayList: BetList {
        listService.lists.first { $0.id == list.id } ?? list
    }

    private var isClosed: Bool { displayList.isClosed }
    private var canVote: Bool { displayList.canVoteOrChangeVote }
    private var isCreator: Bool { displayList.createdBy == currentUserId }
    private var myVote: Vote? { voteService.myVote(listId: list.id ?? "", userId: currentUserId) }
    private var overVotes: [Vote] { voteService.overVotes(listId: list.id ?? "") }
    private var underVotes: [Vote] { voteService.underVotes(listId: list.id ?? "") }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Line: \(displayList.bettingLine, specifier: "%.2f")")
                        .font(.title2.bold())
                    Text("Closes \(displayList.timeLeft)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !displayList.isWithinEditableWindow && !isClosed {
                        Text("Voting closed (only allowed in first 30% of time)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            if isClosed {
                Section("Reveal – Over") {
                    if overVotes.isEmpty {
                        Text("No one picked over")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(overVotes) { v in
                            Label(v.displayName.isEmpty ? "Anonymous" : v.displayName, systemImage: "arrow.up.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
                Section("Reveal – Under") {
                    if underVotes.isEmpty {
                        Text("No one picked under")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(underVotes) { v in
                            Label(v.displayName.isEmpty ? "Anonymous" : v.displayName, systemImage: "arrow.down.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            } else {
                if displayList.locked {
                    Section("Your pick") {
                        Label("Voting is locked", systemImage: "lock.fill")
                            .foregroundStyle(.secondary)
                    }
                } else if !canVote {
                    if let vote = myVote {
                        Section {
                            HStack {
                                Image(systemName: vote.isOver ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    .foregroundStyle(vote.isOver ? .green : .blue)
                                Text("You picked **\(vote.choice)**")
                            }
                        }
                    }
                } else if let vote = myVote {
                    Section {
                        HStack {
                            Image(systemName: vote.isOver ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundStyle(vote.isOver ? .green : .blue)
                            Text("You picked **\(vote.choice)**")
                        }
                    }
                    Section("Change your pick") {
                        Button {
                            Task {
                                await voteService.vote(listId: list.id ?? "", userId: currentUserId, displayName: currentUserName, choice: "over")
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundStyle(.green)
                                Text("Over \(displayList.bettingLine, specifier: "%.2f")")
                            }
                        }
                        Button {
                            Task {
                                await voteService.vote(listId: list.id ?? "", userId: currentUserId, displayName: currentUserName, choice: "under")
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundStyle(.blue)
                                Text("Under \(displayList.bettingLine, specifier: "%.2f")")
                            }
                        }
                    }
                } else {
                    Section("Your pick") {
                        Button {
                            Task {
                                await voteService.vote(listId: list.id ?? "", userId: currentUserId, displayName: currentUserName, choice: "over")
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundStyle(.green)
                                Text("Over \(displayList.bettingLine, specifier: "%.2f")")
                            }
                        }
                        Button {
                            Task {
                                await voteService.vote(listId: list.id ?? "", userId: currentUserId, displayName: currentUserName, choice: "under")
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundStyle(.blue)
                                Text("Under \(displayList.bettingLine, specifier: "%.2f")")
                            }
                        }
                    }
                }
            }

            Section {
                Button(role: .destructive, action: { showDeleteConfirm = true }) {
                    Label("Delete bet", systemImage: "trash")
                }
            }
        }
        .navigationTitle(displayList.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isCreator && !isClosed {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await listService.toggleLock(displayList, byUserId: currentUserId) }
                    } label: {
                        Image(systemName: displayList.locked ? "lock.fill" : "lock.open.fill")
                    }
                    .help(displayList.locked ? "Unlock voting" : "Lock voting")
                }
            }
        }
        .onAppear {
            if let id = list.id {
                voteService.startListeningVotes(listId: id)
            }
            if displayList.isClosed {
                onCloseIfExpired()
            }
        }
        .onDisappear {
            if let id = list.id {
                voteService.stopListeningVotes(listId: id)
            }
        }
        .confirmationDialog("Delete this bet?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All votes will be removed. This can’t be undone.")
        }
    }
}
