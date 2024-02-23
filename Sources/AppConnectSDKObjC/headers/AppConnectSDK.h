//
//  Header.h
//  
//
//  Created by Korn Isaranimitr on 22/2/2567 BE.
//

#ifndef Header_h
#define Header_h


#endif /* Header_h */

#import <Foundation/Foundation.h>
@interface ChannelConfiguration : NSObject

@property(nonatomic) BOOL commitOnRead;

- (instancetype)initWithCommitOnRead:(BOOL)commitOnRead;

@end

@interface Message : NSObject

@property(nonatomic, strong) NSString *message;
@property(nonatomic) NSInteger expiry;

- (instancetype)initWithMessage:(NSString *)message expiry:(NSInteger)expiry;

@end

@interface AppConnectSDK : NSObject

@property(nonatomic, strong) NSString *appGroup;
@property(nonatomic, strong) NSString *source;
@property(nonatomic, strong) NSString *destination;
@property(nonatomic, strong) ChannelConfiguration *config;

- (instancetype)initWithAppGroup:(NSString *)appGroup source:(NSString *)source destination:(NSString *)destination config:(ChannelConfiguration *)config;
- (void)info;
+ (instancetype)createChannelWithAppGroup:(NSString *)appGroup source:(NSString *)source destination:(NSString *)destination config:(ChannelConfiguration *)config;
- (void)sendWithMessage:(NSString *)message expiry:(NSInteger)expiry;
- (NSString *)readWithError:(NSError **)error;
- (void)commit;

@end

@interface AppGroupConnector : NSObject

+ (void)writeWithMessage:(Message *)message appGroup:(NSString *)appGroup key:(NSString *)key;
+ (Message *)readWithAppGroup:(NSString *)appGroup key:(NSString *)key;

@end




typedef NS_ENUM(NSUInteger, MessageType) {
    MessageTypeIN,
    MessageTypeOUT
};
