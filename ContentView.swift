//
//  ContentView.swift
//  rasman
//
//  Created by Lucas J. Chumley on 8/14/24.
//

import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    case accounts = "Users"
    case impersonation = "Impersonation"
    case chats = "Chat Rooms"
    case sessions = "User Sessions"

    var id: String { self.rawValue }
}

struct ContentView: View {
    @State private var selectedItem: SidebarItem? = .accounts
    @State private var isSettingsPresented: Bool = false
    @State private var shouldRefreshAccounts: Bool = false
    @State private var shouldRefreshImpersonation: Bool = false

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selectedItem) { item in
                NavigationLink(value: item) {
                    Text(item.rawValue)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItemGroup {
                    Button(action: {
                        isSettingsPresented.toggle()
                    }) {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .sheet(isPresented: $isSettingsPresented) {
                        ServerSettingsView(shouldRefreshAccounts: $shouldRefreshAccounts)
                            .frame(minWidth: 400, minHeight: 300)
                    }

                    Button(action: {
                        triggerRefresh()
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        } detail: {
            if let selectedItem = selectedItem {
                switch selectedItem {
                case .accounts:
                    AccountsView(shouldRefreshAccounts: $shouldRefreshAccounts)
                case .chats:
                    ChatRoomsView()
                case .impersonation:
                    ImpersonationsView(shouldRefreshImpersonation: $shouldRefreshImpersonation)
                case .sessions:
                    UserSessionsView()
                }
            } else {
                Text("Select a view")
                    .font(.largeTitle)
                    .padding()
            }
        }
        .navigationDestination(for: SidebarItem.self) { item in
            switch item {
            case .accounts:
                AccountsView(shouldRefreshAccounts: $shouldRefreshAccounts)
            case .chats:
                ChatRoomsView()
            case .impersonation:
                ImpersonationsView(shouldRefreshImpersonation: $shouldRefreshImpersonation)
            case .sessions:
                UserSessionsView()
            }
        }
    }

    private func triggerRefresh() {
        switch selectedItem {
        case .accounts:
            shouldRefreshAccounts = true
        case .impersonation:
            shouldRefreshImpersonation = true
            print(shouldRefreshImpersonation)
        default:
            break
        }
    }
}

#Preview {
    ContentView()
}
