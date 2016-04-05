//
//  LDAdvertisingHelper.h
//  GetGems
//
//  Created by Onizhuk Anton on 3/6/16.
//
//

@class LDAdvertisingChannel;
@class TGConversation;

@interface LDAdvertisingManager : NSObject

+ (instancetype)sharedManager;


- (void)setupAdvertising;

- (NSArray <LDAdvertisingChannel *> *)advertisingChannels;


/** join or leave channel
 *  state == YES : join
 *  state == NO  : leave
 *  completion can be called with nil in case of error
 *  or when channel was removed from adv channel configuration
 *  on backend during aplication work
 */
- (void)setState:(BOOL)state forChannel:(LDAdvertisingChannel *)channel completion:(void(^)(LDAdvertisingChannel *, NSError *))completion;
- (void)didLeaveChannelWithID:(int64_t)conversationID;
- (void)didSelectConversation:(TGConversation *)conversation;
- (void)goingToLogout;



@end
