//
//  UserSessionsView.swift
//  rasman
//
//  Created by Lucas J. Chumley on 8/16/24.
//

import SwiftUI
import SwiftData

struct UserSession: Identifiable, Codable {
    let id: String
    let screen_name: String
}

struct UserSessionsView: View {
    @State private var activeSessions: [UserSession] = []
    @State private var isLoading = true
    
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var settings: [ServerSettings]

    var body: some View {
        VStack {
            
            if isLoading {
                ProgressView("Loading sessions...")
                
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    Text("\(activeSessions.count) Active Sessions")
                        .font(.largeTitle)
                        .padding(.bottom, 20)

                    
                    List(activeSessions) { session in
                        VStack(alignment: .leading) {
                            Text(session.screen_name)
                                .font(.headline)
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            fetchSessions()
            print(activeSessions)
        }
    }

    private func fetchSessions() {
        guard let settings = settings.first,
              let url = URL(string: "\(settings.baseURL):\(settings.port)/session") else {
            print("Error: Missing or invalid baseURL/port")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error fetching sessions: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let responseObject = try JSONDecoder().decode(SessionResponse.self, from: data)
                DispatchQueue.main.async {
                    self.activeSessions = responseObject.sessions
                    self.isLoading = false
                }
            } catch {
                print("Error decoding sessions: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct SessionResponse: Codable {
    let count: Int
    let sessions: [UserSession]
}

struct UserSessionsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSessionsView()
    }
}
