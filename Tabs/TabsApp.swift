import SwiftUI
import FirebaseCore

@main
struct TabsApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    ListService.shared.startListening()
                }
                .onDisappear {
                    ListService.shared.stopListening()
                }
        }
    }
}
