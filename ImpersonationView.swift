//
//  ImpersonationView.swift
//  rasman
//
//  Created by Lucas J. Chumley on 8/15/24.
//

import SwiftUI
import Combine
import SwiftData

struct ImpersonationsView: View {
    
    @Query private var settings: [ServerSettings]
    @Query private var sentMessages: [SentMessage]
    @Environment(\.modelContext) private var modelContext
    @State private var fromScreenName: String = ""
    @State private var toScreenName: String = ""
    @State private var messageText: String = ""
    @State private var isLoading: Bool = false
    @State private var statusMessage: String?
    @State private var cancellable: AnyCancellable?
    @Binding var shouldRefreshImpersonation: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("From:")
                        .frame(width: 60, alignment: .leading)
                    TextField("Sender screen name", text: $fromScreenName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                
                HStack {
                    Text("To:")
                        .frame(width: 60, alignment: .leading)
                    TextField("Recipient screen name", text: $toScreenName)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                
                HStack {
                    Text("Message:")
                        .frame(width: 60, alignment: .leading)
                    TextField("Enter message", text: $messageText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
            }
            
            if let statusMessage = statusMessage {
                Text(statusMessage)
                    .font(.headline)
                    .padding()
                
            }
            
            Divider()
            
            List(sentMessages) { message in
                VStack(alignment: .leading) {
                    Text("To: \(message.to)")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                    Text("Message: \(message.message)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Result: \(message.result)")
                        .font(.subheadline)
                        .foregroundColor(message.result.contains("successfully") ? .green : .red)
                    Text(message.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                    
                }
                .disabled(isLoading || fromScreenName.isEmpty || toScreenName.isEmpty || messageText.isEmpty)
            }
        }
        .onAppear {
            print("Loaded Sent Messages: \(sentMessages.count)")
        }
        .onChange(of: shouldRefreshImpersonation) { _ in
            shouldRefreshImpersonation.toggle()
            print("Toggled Refresh")
        }
    }
    
    private func sendMessage() {
        guard let settings = settings.first, !fromScreenName.isEmpty, !toScreenName.isEmpty, !messageText.isEmpty else {
            statusMessage = "All fields are required."
            return
        }
        
        let urlString = "\(settings.baseURL):\(settings.port)/instant-message"
        guard let url = URL(string: urlString) else {
            statusMessage = "Invalid server URL."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messagePayload = ["from": fromScreenName, "to": toScreenName, "text": messageText]
        request.httpBody = try? JSONSerialization.data(withJSONObject: messagePayload)
        
        // Save the message initially with a placeholder result
        let newMessage = saveSentMessage(withResult: "Sending...")
        
        isLoading = true
        statusMessage = nil
        
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isLoading = false
                switch completion {
                case .finished:
                    statusMessage = "Message sent successfully."
                case .failure(let error):
                    statusMessage = "Failed to send message: \(error.localizedDescription)"
                }
                // Update the specific message instance with the actual result
                updateSentMessage(newMessage, withResult: statusMessage ?? "No status")
            }, receiveValue: { _ in })
    }

    private func saveSentMessage(withResult result: String) -> SentMessage {
        let newMessage = SentMessage(
            from: fromScreenName,
            to: toScreenName,
            message: messageText,
            result: result
        )
        
        modelContext.insert(newMessage)
        print("Message saved: \(newMessage.message) with result: \(result)")
        
        clearFields()
        
        return newMessage
    }

    private func updateSentMessage(_ message: SentMessage, withResult result: String) {
        // Update the result of the specific SentMessage instance
        message.result = result
        // Force SwiftData to recognize the change
        do {
            try modelContext.save()
        } catch {
            print("Failed to update message result: \(error)")
        }
        print("Message updated with result: \(message.result)")
    }
    
    private func clearFields() {
        fromScreenName = ""
        toScreenName = ""
        messageText = ""
    }
    
}

#Preview {
    ImpersonationsView(shouldRefreshImpersonation: .constant(false))
}
