# Tabs

Create bets with friends: set a line and expiry, everyone picks over or under, and when time’s up you see who voted what.

## Features

- **Accounts** – Sign in (anonymous); set a display name so your vote is shown in the reveal.
- **Create a bet** – Title, **expiry date/time**, and **betting line** (number). When the list expires, voting is closed.
- **Over / Under** – Each person picks over or under the line (one vote per person per bet).
- **Reveal** – After the bet closes, the app shows who picked over and who picked under.
- **Search** – Filter bets by title.
- **Sign out** – In the main screen toolbar.

## Requirements

- Xcode 15+ (Swift 5.9, iOS 17+)
- Firebase project with **Authentication** (Anonymous sign-in) and **Firestore** enabled

## Setup

### 1. Open the project

```bash
open Tabs.xcodeproj
```

### 2. Add the Firebase config file (not in repo – contains secrets)

`GoogleService-Info.plist` is **not** committed (see `.gitignore`). Add it like this:

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Create a project (or use an existing one).
3. Add an **iOS app** with bundle ID: `com.cillian.tabs` (or your chosen bundle ID).
4. Download **GoogleService-Info.plist** from the Firebase project settings.
5. Put the downloaded file in the **`Tabs/`** folder (same directory as TabsApp.swift). In Xcode, drag it into the Tabs group and ensure the Tabs target is checked.

Alternatively, copy `Tabs/GoogleService-Info-Template.plist` to `Tabs/GoogleService-Info.plist` and replace the placeholder values with your Firebase project's values.

If you previously committed `GoogleService-Info.plist`, remove it from the repo (keep your local file):  
`git rm --cached Tabs/GoogleService-Info.plist` then commit.

### 3. Enable Firebase Auth (Anonymous)

1. In Firebase Console, open **Build → Authentication**.
2. Sign-in method **Anonymous** → Enable → Save.

### 4. Enable Firestore

1. In Firebase Console, open **Build → Firestore Database**.
2. Click **Create database** and choose **Start in test mode** (or set your own rules; see below).

### 5. Firestore rules (test mode vs production)

**Test mode** (signed-in users can read/write; fine for trying with friends):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /lists/{listId} {
      allow read, write: if request.auth != null;
      match /votes/{voteId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

For production, tighten as needed (e.g. restrict who can create/delete lists). The app uses:

- **`users/{userId}`** – display name (written by that user).
- **`lists`** – each document: title, createdBy, createdByName, createdAt, expiresAt, bettingLine, status.
- **`lists/{listId}/votes`** – each vote: userId, displayName, choice ("over" | "under"), votedAt.

### 6. Build and run

Select a simulator or device and run (⌘R). The first time you run, Xcode will resolve the Firebase Swift Package Manager dependency. Add **FirebaseAuth** if prompted (File → Add Package Dependencies → firebase-ios-sdk → FirebaseAuth).

## Repository

This project is the **Tabs** repo. To rename the GitHub repo to **Tabs**: GitHub → Your repo → Settings → Repository name → change to `Tabs` → Rename.

## Project structure

- **TabsApp.swift** – App entry; configures Firebase, starts ListService.
- **ContentView.swift** – Auth gate; list of bets, search, create, sign out; navigates to list detail.
- **Models/BetList.swift** – List with title, expiresAt, bettingLine, status.
- **Models/Vote.swift** – Vote with userId, displayName, choice (over/under).
- **Services/AuthService.swift** – Anonymous sign-in, display name (Firestore users/{uid}).
- **Services/ListService.swift** – CRUD for lists, close when expired.
- **Services/VoteService.swift** – Vote over/under, listen votes per list.
- **Views/AuthView.swift** – Sign in, set display name.
- **Views/CreateListView.swift** – New bet: title, expiry, line.
- **Views/ListDetailView.swift** – Line, time left; pick over/under; when closed, reveal who voted what.
- **Views/BetListRowView.swift** – Row: title, line, vote count, time left / Ended.
