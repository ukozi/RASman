//
//  Item.swift
//  rasman
//
//  Created by Lucas J. Chumley on 8/14/24.
//

import Foundation
import SwiftData

@Model
final class ServerSettings {
    @Attribute var baseURL: String
    @Attribute var port: String
    
    init(baseURL: String = "", port: String = "") {
        self.baseURL = baseURL
        self.port = port
    }
}

@Model
final class SentMessage {
    @Attribute var from: String
    @Attribute var to: String
    @Attribute var message: String
    @Attribute var result: String
    @Attribute var timestamp: Date

    init(from: String, to: String, message: String, result: String) {
        self.from = from
        self.to = to
        self.message = message
        self.result = result
        self.timestamp = Date()
    }
}
