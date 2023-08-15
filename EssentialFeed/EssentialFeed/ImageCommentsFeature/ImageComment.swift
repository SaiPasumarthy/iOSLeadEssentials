//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 15/08/23.
//

import Foundation

public struct ImageComment: Equatable {
    public init(id: UUID, message: String, createdAt: Date, username: String) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.username = username
    }
    
    public let id: UUID
    public let message: String
    public let createdAt: Date
    public let username: String
}
