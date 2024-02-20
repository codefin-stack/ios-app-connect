//
//  File.swift
//  
//
//  Created by Korn Isaranimitr on 20/2/2567 BE.
//

import Foundation

public enum MessageType {
    case IN
    case OUT
}

public class Message: Codable {
    var message : String
    var expiry : Int
    
    public init(
        message: String,
        expiry: Int
    ) {
        self.message = message
        self.expiry = expiry
    }
}
