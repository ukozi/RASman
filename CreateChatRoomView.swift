//
//  CreateChatRoomView.swift
//  RASman
//
//  Created by Lucas J. Chumley on 8/16/24.
//

import SwiftUI

struct CreateChatRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @State private var chatRoomName: String = ""
    @State private var chatRoomType: String = "Public"
    
    @Binding var isCreating: Bool
    
    let createChatRoom: (String, String) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Create New Chat Room")
                .font(.title)
                .padding(.bottom)
            
            TextField("Chat Room Name", text: $chatRoomName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom)
            
            Picker("Chat Room Type", selection: $chatRoomType) {
                Text("Public").tag("Public")
                Text("Private").tag("Private")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom)
            
            HStack {
                Spacer()
                Button("Create") {
                    createChatRoom(chatRoomName, chatRoomType)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(chatRoomName.isEmpty)
                .padding()
            }
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
}
