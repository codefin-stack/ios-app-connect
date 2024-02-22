// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class AppConnectSDK {
    
    // Properties
    var appGroup: String
    var source: String
    var destination: String
    var config: ChannelConfiguration
    
    // Initializer
    init(appGroup: String, source: String, destination: String, config: ChannelConfiguration) {
        self.appGroup = appGroup
        self.source = source
        self.destination = destination
        self.config = config
    }
    
    // Method to greet
    func info() {
        print("This channel want to send data from \(source) to \(destination).")
    }
    
    // Static factory method
    static public func createChannel(
        appGroup: String,
        source: String,
        destination: String,
        config: ChannelConfiguration
    ) -> AppConnectSDK {
        return AppConnectSDK(appGroup: appGroup, source: source, destination: destination, config: config)
    }
    
    public func send(message: String, expiry: Int) {
        print("[AppConnectSDK:send] called with ", message, expiry)
        var key = getChannelId(source: source, destination: destination, type: MessageType.OUT)
        
        print("[AppConnectSDK:send] key: ", key)
        AppGroupConnector.write(
            message: Message(
                message: message,
                expiry: expiry
            ),
            appGroup: appGroup,
            key: key
        )
    }
    
    public func read() throws -> String {
        print("[AppConnectSDK:read] called")
        var otherKey: String = getChannelId(source: destination, destination: source, type: MessageType.OUT)
        print("[AppConnectSDK:send] otherKey: ", otherKey)
        var selfKey: String = getChannelId(source: source, destination: destination, type: MessageType.IN)
        print("[AppConnectSDK:send] selfKey: ", selfKey)
        
        var incomingMessage = AppGroupConnector.read(
            appGroup: appGroup,
            key: otherKey
        )
        
        if (incomingMessage == nil) {
            throw AppConnectError.MessageNotFound
        }
        
        print("[AppConnectSDK:send] incomingMessage: ", incomingMessage?.message ?? "")
        
        var readedMessage = AppGroupConnector.read(
            appGroup: appGroup,
            key: selfKey
        )
        
        
        
        
        if (readedMessage != nil) {
            print("[AppConnectSDK:send] readedMessage: ", readedMessage?.message ?? "")
            if (readedMessage!.message == incomingMessage?.message) {
                throw AppConnectError.MessageAlreadyRead
            }
            let currentTime = Int(Date().timeIntervalSince1970 * 1000)
            print("[AppConnectSDK:send] currentTime: ", currentTime)
            print("[AppConnectSDK:send] readedMessage expiry: ", readedMessage?.expiry ?? "")
            if (currentTime > readedMessage!.expiry) {
                throw AppConnectError.MessageHasExpired
            }
        }
        
        return incomingMessage!.message
    }
    
    public func commit() {
        print("[AppConnectSDK:commit] called")
        var otherKey: String = getChannelId(source: destination, destination: source, type: MessageType.OUT)
        var selfKey: String = getChannelId(source: source, destination: destination, type: MessageType.IN)
        
        print("[AppConnectSDK:commit] otherKey: ", otherKey)
        print("[AppConnectSDK:commit] selfKey: ", selfKey)
        
        var incomingMessage = AppGroupConnector.read(
            appGroup: appGroup,
            key: otherKey
        )
        
        if (incomingMessage == nil) {
            return
        }
        
        AppGroupConnector.write(
            message: incomingMessage!,
            appGroup: appGroup,
            key: selfKey
        )
    }
}

public class AppGroupConnector {
    public static func write(message: Message, appGroup: String, key: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(message)
            if let sharedDefaults = UserDefaults(suiteName: appGroup) {
                sharedDefaults.set(data, forKey: key)
                sharedDefaults.synchronize() // Make sure to synchronize to save the changes immediately
            }
        } catch {
            print("Error encoding object:", error)
        }
    }
    
    public static func read(appGroup: String, key: String) -> Message? {
        if let sharedDefaults = UserDefaults(suiteName: appGroup) {
            if let data = sharedDefaults.data(forKey: key) {
                let decoder = JSONDecoder()
                do {
                    let object = try decoder.decode(Message.self, from: data)
                    return object
                } catch {
                    print("Error decoding object:", error)
                }
            }
        }
        return nil
    }
}

public class ChannelConfiguration {
    var commitOnRead: Bool
    
    public init(commitOnRead: Bool) {
        self.commitOnRead = commitOnRead
    }
}


private func getChannelId(source: String, destination: String, type: MessageType) -> String {
    var arr = [source, destination]
    arr.sort()
    var channelId = arr.joined(separator: "_")
    return "\(source)_\(channelId)_\(type)"
}

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

enum AppConnectError: Error {
    case MessageNotFound
    case MessageAlreadyRead
    case MessageHasExpired
}
