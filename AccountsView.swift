//
//  AccountsView.swift
//  rasman
//
//  Created by Lucas J. Chumley on 8/14/24.
//

import SwiftUI
import Combine
import SwiftData

struct AccountsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [ServerSettings]
    @State private var users: [User] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var cancellable: AnyCancellable?
    @State private var isAddUserPresented: Bool = false
    @State private var isChangePasswordPresented: Bool = false
    @State private var selectedUser: User?
    @State private var isDeleteConfirmationPresented: Bool = false
    @Binding var shouldRefreshAccounts: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Users")
                .font(.largeTitle)
                .padding(.bottom, 20)

            if settings.isEmpty {
                Text("Server settings must be configured to continue.")
                    .font(.headline)
                    .foregroundColor(.red)
            } else {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if isLoading {
                    ProgressView("Loading Users...")
                        .padding()
                } else {
                    List {
                        ForEach(users) { user in
                            HStack {
                                Text(user.screenName)
                                Spacer()
                                Button("Change Password") {
                                    changePassword(user: user)
                                }
                                .buttonStyle(.bordered)
                                Button("Delete", role: .destructive) {
                                    selectedUser = user
                                    isDeleteConfirmationPresented.toggle()
                                }
                                
                            }
                            .contextMenu {
                                Button("Delete", action: { deleteUser(user: user) })
                            }
                        }
                    }
                    .padding(.bottom, 20)

                }
            }
        }
        .padding()
        .onAppear(perform: loadUsers)
        .onChange(of: shouldRefreshAccounts) { newValue in
            if newValue {
                loadUsers()
                shouldRefreshAccounts = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    isAddUserPresented.toggle()
                }) {
                    Label("Add User", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddUserPresented) {
            AddUserView(baseURL: settings.first?.baseURL ?? "", port: settings.first?.port ?? "", shouldRefreshAccounts: $shouldRefreshAccounts)
        }
        .sheet(isPresented: $isChangePasswordPresented) {
            if let selectedUser = selectedUser {
                ChangePasswordView(baseURL: settings.first?.baseURL ?? "", port: settings.first?.port ?? "", screenName: selectedUser.screenName)
            }
        }
        .alert(isPresented: $isDeleteConfirmationPresented) {
            Alert(
                title: Text("Delete User"),
                message: Text("Are you sure you want to delete the user \(selectedUser?.screenName ?? "")?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let user = selectedUser {
                        deleteUser(user: user)
                    }
                },
                secondaryButton: .cancel()
            )
        }

    }

    private func loadUsers() {
        guard let settings = settings.first else { return }
        
        let urlString = "\(settings.baseURL):\(settings.port)/user"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid server URL."
            return
        }

        isLoading = true
        errorMessage = nil

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: [User].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    errorMessage = "Failed to load users: \(error.localizedDescription)"
                }
            }, receiveValue: { users in
                self.users = users
            })
    }

    private func deleteUser(user: User) {
        guard let settings = settings.first else { return }
        
        let urlString = "\(settings.baseURL):\(settings.port)/user"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid server URL."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["screen_name": user.screenName])

        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 204 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    loadUsers()
                case .failure(let error):
                    errorMessage = "Failed to delete user: \(error.localizedDescription)"
                }
            }, receiveValue: { _ in })
    }

    private func deleteAllUsers() {
        for user in users {
            deleteUser(user: user)
        }
    }

    private func changePassword(user: User) {
        selectedUser = user
        isChangePasswordPresented.toggle()
    }
}

struct User: Identifiable, Codable {
    var id: String
    var screenName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case screenName = "screen_name"
    }
}

#Preview {
    AccountsView(shouldRefreshAccounts: .constant(false))
        .modelContainer(for: ServerSettings.self, inMemory: true)
}
