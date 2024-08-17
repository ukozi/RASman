//
//  AddUserView.swift
//  rasman
//
//  Created by Lucas J. Chumley on 8/14/24.
//

import SwiftUI
import Combine

struct AddUserView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var screenName: String = ""
    @State private var password: String = ""
    @State private var isICQ: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var cancellable: AnyCancellable?

    var baseURL: String
    var port: String
    @Binding var shouldRefreshAccounts: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add New User")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            HStack {
                Text("Screen Name:")
                    .frame(width: 100, alignment: .leading)
                TextField("Enter screen name", text: $screenName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 250)
            }
            
            HStack {
                Text("Password:")
                    .frame(width: 100, alignment: .leading)
                SecureField("Enter password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 250)
            }
            
            Toggle("ICQ User", isOn: $isICQ)
                .toggleStyle(SwitchToggleStyle())
                .frame(width: 350, alignment: .leading)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.headline)
                    .padding()
            }

            Spacer()

            Button("Add User") {
                addUser()
            }
            .disabled(isLoading || screenName.isEmpty || password.isEmpty)
            .padding(.top, 20)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .buttonStyle(.bordered)

            
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    shouldRefreshAccounts = true
                    dismiss()
                }
            }
        }
    }

    private func addUser() {
        guard !screenName.isEmpty, !password.isEmpty else {
            errorMessage = "Screen Name and Password cannot be empty."
            return
        }
        
        let urlString = "\(baseURL):\(port)/user"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid server URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let newUser = ["screen_name": screenName, "password": password, "is_icq": isICQ] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: newUser)

        isLoading = true
        errorMessage = nil

        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 201 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isLoading = false
                switch completion {
                case .finished:
                    errorMessage = "User added successfully."
                    clearFields()
                case .failure(let error):
                    errorMessage = "Failed to add user: \(error.localizedDescription)"
                }
            }, receiveValue: { _ in })
    }
    
    private func clearFields() {
        screenName = ""
        password = ""
        isICQ = false
    }
}

#Preview {
    AddUserView(baseURL: "http://localhost", port: "8080", shouldRefreshAccounts: .constant(false))
}
