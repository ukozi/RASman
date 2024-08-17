//
//  ChatRoomsView.swift
//  rasman
//
//  Created by Lucas J. Chumley on 8/16/24.
//

import SwiftUI
import SwiftData

struct ChatRoom: Identifiable, Codable {
    let id = UUID()
    let name: String
    let create_time: String
    let creator_id: String?
    let url: String?
    let participants: [Participant]?
}

struct Participant: Identifiable, Codable {
    let id: String
    let screen_name: String
}

struct ChatRoomsView: View {
    @State private var publicChatRooms: [ChatRoom] = []
    @State private var privateChatRooms: [ChatRoom] = []
    @State private var isLoadingPublic = true
    @State private var isLoadingPrivate = true
    @State private var selectedChatRoom: ChatRoom?
    @State private var isShowingCreateChatRoom = false
    
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var settings: [ServerSettings]
    
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .leading) {
                
                Text("Chat Rooms")
                    .font(.largeTitle)
                
                if isLoadingPublic && isLoadingPrivate {
                    ProgressView("Loading chat rooms...")
                } else {
                    if !publicChatRooms.isEmpty || publicChatRooms.isEmpty {
                        Text("Public Chat Rooms")
                            .font(.headline)
                            .padding(.top)
                        
                        List(publicChatRooms) { chatRoom in
                            NavigationLink(destination: ChatRoomDetailView(chatRoom: chatRoom)) {
                                VStack(alignment: .leading) {
                                    Text(chatRoom.name)
                                        .font(.headline)
                                    
                                    if let participants = chatRoom.participants {
                                        Text("\(participants.count) Participants")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        
                        Divider()
                    }
                    
                    if !privateChatRooms.isEmpty || privateChatRooms.isEmpty {
                        Text("Private Chat Rooms")
                            .font(.headline)
                            .padding(.top)
                        
                        List(privateChatRooms) { chatRoom in
                            NavigationLink(destination: ChatRoomDetailView(chatRoom: chatRoom)) {
                                VStack(alignment: .leading) {
                                    Text(chatRoom.name)
                                        .font(.headline)
                                    if let participants = chatRoom.participants {
                                        Text("\(participants.count) Participants")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isShowingCreateChatRoom = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingCreateChatRoom) {
                CreateChatRoomView(isCreating: $isLoadingPublic, createChatRoom: createChatRoom)
            }
            .onAppear {
                fetchPublicChatRooms()
                fetchPrivateChatRooms()
            }
        } 
    }
    
    private func createChatRoom(name: String, type: String) {
        guard let settings = settings.first else { return }
        let endpoint = type == "Public" ? "/chat/room/public" : "/chat/room/private"
        guard let url = URL(string: "\(settings.baseURL):\(settings.port)\(endpoint)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["name": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error creating chat room: \(error)")
                return
            }

            fetchPublicChatRooms()
            fetchPrivateChatRooms()
        }.resume()
    }
    
    private func fetchPublicChatRooms() {
        guard let settings = settings.first,
              let url = URL(string: "\(settings.baseURL):\(settings.port)/chat/room/public") else {
            print("Error: Missing or invalid baseURL/port")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error fetching public chat rooms: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON: \(jsonString)")
                }
                let responseObject = try JSONDecoder().decode([ChatRoom].self, from: data)
                DispatchQueue.main.async {
                    self.publicChatRooms = responseObject
                    self.isLoadingPrivate = false
                }
            } catch {
                print("Error decoding private chat rooms: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func fetchPrivateChatRooms() {
        guard let settings = settings.first,
              let url = URL(string: "\(settings.baseURL):\(settings.port)/chat/room/private") else {
            print("Error: Missing or invalid baseURL/port")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error fetching private chat rooms: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON: \(jsonString)")
                }
                let responseObject = try JSONDecoder().decode([ChatRoom].self, from: data)
                DispatchQueue.main.async {
                    self.privateChatRooms = responseObject
                    self.isLoadingPrivate = false
                }
            } catch {
                print("Error decoding private chat rooms: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct ChatRoomsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomsView()
    }
}
