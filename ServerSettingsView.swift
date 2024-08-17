//
//  ServerSettingsView.swift
//  rasman
//
//  Created by Lucas J. Chumley on 8/14/24.
//

import SwiftUI
import Combine
import SwiftData

struct ServerSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [ServerSettings]
    @Environment(\.dismiss) private var dismiss
    @Binding var shouldRefreshAccounts: Bool

    @State private var statusMessage: String = ""
    @State private var isSuccess: Bool? = nil
    @State private var cancellable: AnyCancellable?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Server Settings")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            HStack {
                Text("Base URL:")
                    .frame(width: 100, alignment: .leading)
                TextField("Enter base URL", text: Binding(
                    get: { settings.first?.baseURL ?? "" },
                    set: { newValue in settings.first?.baseURL = newValue }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 250)
            }
            
            HStack {
                Text("Port:")
                    .frame(width: 100, alignment: .leading)
                TextField("Enter port", text: Binding(
                    get: { settings.first?.port ?? "" },
                    set: { newValue in settings.first?.port = newValue }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100)
            }
            
            Button("Test Connection") {
                testConnection()
            }
            .padding(.top, 10)
            
            if let isSuccess = isSuccess {
                HStack {
                    Text(isSuccess ? "✅ Success: " : "❌ Failure: ")
                    Text(statusMessage)
                        .foregroundColor(isSuccess ? .green : .red)
                }
                .padding(.top, 10)
            }
            
            Spacer()
            
            Button("Save and Close") {
                saveSettings()
                shouldRefreshAccounts = true
                dismiss()
            }
            .padding(.top, 20)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .onAppear {
            if settings.isEmpty {
                let newSettings = ServerSettings()
                modelContext.insert(newSettings)
            }
        }
    }

    private func testConnection() {
        guard let settings = settings.first,
              let url = URL(string: "\(settings.baseURL):\(settings.port)/user") else {
            self.isSuccess = false
            self.statusMessage = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                return response
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.isSuccess = false
                    self.statusMessage = error.localizedDescription
                }
            }, receiveValue: { response in
                if response.statusCode == 200 {
                    self.isSuccess = true
                    self.statusMessage = "Successfully connected to the server."
                } else {
                    self.isSuccess = false
                    self.statusMessage = "Server returned status code: \(response.statusCode)"
                }
            })
    }
    
    private func saveSettings() {
        if let settings = settings.first {
            modelContext.insert(settings)
        }
    }
}

#Preview {
    ServerSettingsView(shouldRefreshAccounts: .constant(false))
        .modelContainer(for: ServerSettings.self, inMemory: true)
}
