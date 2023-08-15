//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 15/08/23.
//

import Foundation

public final class FeedImageDataMapper {
    private enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw Error.invalidData
        }
        
        return data
    }
}
