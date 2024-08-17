//
//  ChatRoomDetailView.swift
//  rasman
//
//  Created by Lucas J. Chumley on 8/16/24.
//

import SwiftUI

struct ChatRoomDetailView: View {
    let chatRoom: ChatRoom

    var body: some View {
        VStack(alignment: .leading) {
            Text(chatRoom.name)
                .font(.largeTitle)
                

            
           
            if let creatorID = chatRoom.creator_id {
                Text("Created by \(creatorID) at \(chatRoom.create_time) ")
                    .font(.subheadline)
                    .padding(.bottom)
            }
            
            HStack {
                Text("Address:")
                    .padding(.trailing)
                
                if let chatroomURL = chatRoom.url {
                    Link(chatroomURL, destination: URL(string: chatroomURL)!)
                }
            }
            .padding(.bottom)

            if let participants = chatRoom.participants {
                Text("Participants (\(participants.count))")
                    .font(.headline)
                    .padding(.bottom)

                List(participants) { participant in
                    Text(participant.screen_name)
                }
            }

            Spacer()

        }
        .padding()
    }
}
