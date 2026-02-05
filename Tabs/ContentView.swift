import SwiftUI

struct ContentView: View {
    @StateObject private var auth = AuthService.shared
    @StateObject private var listService = ListService.shared
    @StateObject private var voteService = VoteService.shared
    @State private var searchText = ""
    @State private var showingCreate = false
    @State private var selectedList: BetList?

    private var filteredLists: [BetList] {
        let list = listService.lists
        guard !searchText.isEmpty else { return list }
        let q = searchText.lowercased()
        return list.filter { $0.title.lowercased().contains(q) }
    }

    var body: some View {
        Group {
            if !auth.isSignedIn || !auth.hasDisplayName {
                AuthView()
            } else {
                NavigationStack {
                    Group {
                        if filteredLists.isEmpty {
                            ContentUnavailableView(
                                searchText.isEmpty ? "No bets yet" : "No results for \"\(searchText)\"",
                                systemImage: searchText.isEmpty ? "list.bullet.rectangle" : "magnifyingglass",
                                description: Text(searchText.isEmpty ? "Create a bet and invite friends to pick over or under the line." : "Try a different search.")
                            )
                        } else {
                            List {
                                ForEach(filteredLists) { list in
                                    Button {
                                        selectedList = list
                                    } label: {
                                        BetListRowView(
                                            list: list,
                                            voteCount: voteService.votesForList(list.id ?? "").count
                                        )
                                    }
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search bets")
                    .navigationTitle("Tabs")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                showingCreate = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Sign out") {
                                auth.signOut()
                            }
                            .font(.subheadline)
                        }
                    }
                    .sheet(isPresented: $showingCreate) {
                        CreateListView { title, expiresAt, line in
                            Task {
                                await listService.createList(
                                    title: title,
                                    expiresAt: expiresAt,
                                    bettingLine: line,
                                    createdBy: auth.currentUser?.uid ?? "",
                                    createdByName: auth.displayName
                                )
                            }
                        }
                    }
                    .navigationDestination(item: $selectedList) { list in
                        ListDetailView(
                            list: list,
                            currentUserId: auth.currentUser?.uid ?? "",
                            currentUserName: auth.displayName,
                            onCloseIfExpired: {
                                Task { await listService.closeListIfExpired(list) }
                            },
                            onDelete: {
                                Task {
                                    await listService.deleteList(list)
                                    selectedList = nil
                                }
                            }
                        )
                    }
                    .overlay(alignment: .bottom) {
                        if let msg = listService.errorMessage ?? voteService.errorMessage {
                            Text(msg)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(8)
                        }
                    }
                    .onAppear {
                        for list in listService.lists {
                            if let id = list.id { voteService.startListeningVotes(listId: id) }
                        }
                    }
                    .onChange(of: listService.lists.count) { _, _ in
                        for list in listService.lists {
                            if let id = list.id { voteService.startListeningVotes(listId: id) }
                        }
                    }
                }
            }
        }
    }
}
