//
//  ChangePasswordView.swift
//  rasman
//
//  Created by Lucas J. Chumley on 8/15/24.
//

import SwiftUI
import Combine

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var cancellable: AnyCancellable?

    var baseURL: String
    var port: String
    var screenName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Change Password for \(screenName)")
                .font(.largeTitle)
                .padding(.bottom, 5)


            HStack {
                Text("New Password:")
                    .frame(width: 140, alignment: .leading)
                SecureField("Enter new password", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 250)
            }
            
            HStack {
                Text("Confirm Password:")
                    .frame(width: 140, alignment: .leading)
                SecureField("Confirm new password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 250)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()

            Button("Change Password") {
                changePassword()
            }
            .disabled(isLoading || newPassword.isEmpty || newPassword != confirmPassword)
            .padding(.top, 20)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .buttonStyle(.bordered)


        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }

    private func changePassword() {
        guard !newPassword.isEmpty, newPassword == confirmPassword else { return }
        
        let urlString = "\(baseURL):\(port)/user/password"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid server URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let passwordChangeRequest = ["screen_name": screenName, "password": newPassword]
        request.httpBody = try? JSONSerialization.data(withJSONObject: passwordChangeRequest)

        isLoading = true
        errorMessage = nil

        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 204 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isLoading = false
                switch completion {
                case .finished:
                    dismiss()
                case .failure(let error):
                    errorMessage = "Failed to change password: \(error.localizedDescription)"
                }
            }, receiveValue: { _ in })
    }
}

#Preview {
    ChangePasswordView(baseURL: "http://localhost", port: "8080", screenName: "testuser")
}
