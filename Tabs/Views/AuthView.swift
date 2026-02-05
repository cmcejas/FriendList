import SwiftUI

struct AuthView: View {
    @StateObject private var auth = AuthService.shared
    @State private var displayNameInput = ""
    @FocusState private var isNameFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Tabs")
                .font(.largeTitle.bold())
            Text("Sign in to create and join bets with friends.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if auth.isSignedIn && !auth.hasDisplayName {
                VStack(spacing: 12) {
                    TextField("Your name", text: $displayNameInput)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .focused($isNameFocused)
                        .padding(.horizontal, 40)
                    Button {
                        Task { await auth.setDisplayName(displayNameInput) }
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(displayNameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal, 40)
                }
                .padding(.top, 8)
            } else if !auth.isSignedIn {
                Button {
                    Task { await auth.signInAnonymously() }
                } label: {
                    Text("Sign in to get started")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 40)
            }

            if let msg = auth.errorMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            Spacer()
        }
        .onAppear { isNameFocused = true }
    }
}
