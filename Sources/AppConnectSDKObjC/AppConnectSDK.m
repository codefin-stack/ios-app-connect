//
//  AppConnectSDK.m
//  
//
//  Created by Korn Isaranimitr on 22/2/2567 BE.
//

#import <Foundation/Foundation.h>
#import "AppConnectSDK.h"

@implementation AppConnectSDK

- (instancetype)initWithAppGroup:(NSString *)appGroup source:(NSString *)source destination:(NSString *)destination config:(ChannelConfiguration *)config {
    self = [super init];
    if (self) {
        _appGroup = appGroup;
        _source = source;
        _destination = destination;
        _config = config;
    }
    return self;
}
//
- (void)info {
    NSLog(@"This channel want to send data from %@ to %@", _source, _destination);
}

+ (instancetype)createChannelWithAppGroup:(NSString *)appGroup source:(NSString *)source destination:(NSString *)destination config:(ChannelConfiguration *)config {
    return [[AppConnectSDK alloc] initWithAppGroup:appGroup source:source destination:destination config:config];
}

- (void)sendWithMessage:(NSString *)message expiry:(NSInteger)expiry {
    NSLog(@"[AppConnectSDK:send] called with %@ %ld", message, (long)expiry);
    NSString *key = [self getChannelIdWithSource:_source destination:_destination type:MessageTypeOUT];
    NSLog(@"[AppConnectSDK:send] key: %@", key);
    [AppGroupConnector writeWithMessage:[[Message alloc] initWithMessage:message expiry:expiry] appGroup:_appGroup key:key];
}

- (NSString *)readWithError:(NSError **)error {
    NSLog(@"[AppConnectSDK:read] called");
    NSString *otherKey = [self getChannelIdWithSource:_destination destination:_source type:MessageTypeOUT];
    NSLog(@"[AppConnectSDK:send] otherKey: %@", otherKey);
    NSString *selfKey = [self getChannelIdWithSource:_source destination:_destination type:MessageTypeIN];
    NSLog(@"[AppConnectSDK:send] selfKey: %@", selfKey);
    
    Message *incomingMessage = [AppGroupConnector readWithAppGroup:_appGroup key:otherKey];
    
    if (!incomingMessage) {
        *error = [NSError errorWithDomain:@"AppConnectErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Message not found"}];
        return nil;
    }
    
    NSLog(@"[AppConnectSDK:send] incomingMessage: %@", incomingMessage.message);
    
    Message *readedMessage = [AppGroupConnector readWithAppGroup:_appGroup key:selfKey];
    
    if (readedMessage) {
        NSLog(@"[AppConnectSDK:send] readedMessage: %@", readedMessage.message);
        if ([readedMessage.message isEqualToString:incomingMessage.message]) {
            *error = [NSError errorWithDomain:@"AppConnectErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Message already read"}];
            return nil;
        }
        NSInteger currentTime = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
        NSLog(@"[AppConnectSDK:send] currentTime: %ld", (long)currentTime);
        NSLog(@"[AppConnectSDK:send] readedMessage expiry: %ld", (long)incomingMessage.expiry);
        if (currentTime > incomingMessage.expiry) {
            *error = [NSError errorWithDomain:@"AppConnectErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Message has expired"}];
            return nil;
        }
    }
    
    return incomingMessage.message;
}

- (void)commit {
    NSLog(@"[AppConnectSDK:commit] called");
    NSString *otherKey = [self getChannelIdWithSource:_destination destination:_source type:MessageTypeOUT];
    NSString *selfKey = [self getChannelIdWithSource:_source destination:_destination type:MessageTypeIN];
    
    NSLog(@"[AppConnectSDK:commit] otherKey: %@", otherKey);
    NSLog(@"[AppConnectSDK:commit] selfKey: %@", selfKey);
    
    Message *incomingMessage = [AppGroupConnector readWithAppGroup:_appGroup key:otherKey];
    
    if (!incomingMessage) {
        return;
    }
    
    [AppGroupConnector writeWithMessage:incomingMessage appGroup:_appGroup key:selfKey];
}

- (NSString *)getChannelIdWithSource:(NSString *)source destination:(NSString *)destination type:(MessageType)type {
    NSString *myString = @"";
    if (type == MessageTypeIN) {
        myString = @"IN";
    } else {
        myString = @"OUT";
    }
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:source, destination, nil];
    [arr sortUsingSelector:@selector(compare:)];
    NSString *channelId = [arr componentsJoinedByString:@"_"];
    return [NSString stringWithFormat:@"%@_%@_%@", source, channelId, myString];
}

@end

@implementation AppGroupConnector

+ (void)writeWithMessage:(Message *)message appGroup:(NSString *)appGroup key:(NSString *)key {
    NSLog(@"[AppConnectSDK.AppGroupConnector readWithAppGroup] called with %@ - and key %@", appGroup, key);
    NSLog(@"[AppConnectSDK.AppGroupConnector readWithAppGroup] called with message %@ - %ld", message.message, message.expiry);
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"message": message.message ?: [NSNull null], @"expiry": @(message.expiry)} options:0 error:&error];

  if (data && !error) {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
      NSLog(@"[AppConnectSDK.AppGroupConnector readWithAppGroup] data is %@", data);
    [sharedDefaults setObject:data forKey:key];
    [sharedDefaults synchronize];
  } else {
    NSLog(@"Error encoding object: %@", error);
  }
}

+ (Message *)readWithAppGroup:(NSString *)appGroup key:(NSString *)key {
  NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
  NSData *data = [sharedDefaults objectForKey:key];
  if (data) {
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if ([jsonObject isKindOfClass:[NSDictionary class]] && !error) {
      NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
      NSString *messageText = jsonDictionary[@"message"];
      NSInteger expiry = [jsonDictionary[@"expiry"] integerValue];

      // Create a new instance of the Message class
      Message *message = [[Message alloc] initWithMessage:messageText expiry:expiry];

      // Now you can use the 'message' object
      NSLog(@"Message: %@", message.message);
      NSLog(@"Expiry: %ld", (long)message.expiry);
      return [[Message alloc] initWithMessage:jsonObject[@"message"] expiry:[jsonObject[@"expiry"] integerValue]];
    } else {
      NSLog(@"Error decoding object: %@", error);
    }
  }
  return nil;
}
@end

@implementation ChannelConfiguration

- (instancetype)initWithCommitOnRead:(BOOL)commitOnRead 
{
    self = [super init];
    if (self) {
        self.commitOnRead = commitOnRead;
    }
    return self;
}

@end


@implementation Message

- (instancetype)initWithMessage:(NSString *)message expiry:(NSInteger)expiry {
    self = [super init];
    if (self) {
        self.message = message;
        self.expiry = expiry;
    }
    return self;
}

@end
