//
//  GemsBotConfiguration.h
//  GetGems
//
//  Created by alon muroch on 5/20/15.
//
//

#import <Foundation/Foundation.h>
#import "TGUser+Telegraph.h"
#import "ASHandle.h"

@interface GemsBotConfiguration : NSObject <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@property(nonatomic, strong) TGUser *tgUser;
@property(nonatomic, strong) NSString *telegramUserName;
@property(nonatomic, strong) NSString *phoneNumber;
@property(nonatomic) int32_t tgID;
@property(nonatomic) int64_t accessHash;
@property(nonatomic, assign) int consecutiveTries;

@property (nonatomic, strong) void (^sendingCompletionBlock)(NSDictionary *data, NSString *error);
@property (nonatomic, strong) void (^botResponseBlock)(NSString *data);
@property (nonatomic, strong) void (^botTimeoutBlock)(NSDictionary *data);
@property (nonatomic, strong) void (^botAddedToContacts)(BOOL result);

@property (nonatomic) int32_t timeoutInSeconds;

@property(nonatomic, assign) BOOL deleteBotConversationWhenFinished;

- (instancetype)initWithTelegramUsername:(NSString*)username;
- (void)prepareBotWithCompletion:(void (^)(void))completion;

- (NSDictionary *)optionsForMessageActions;
- (NSString *)messagePathForMessageId:(int32_t)mid;
- (NSString *)messagePathPrefix;

- (BOOL)inContacts;

- (BOOL)maybeCallBotAddedToContacts:(BOOL)result;
- (void)maybeCallMessageDeliveryCompletionBlockWithError:(NSString*)error;
- (void)maybeCallMessageDeliveryCompletionBlockWithData:(NSDictionary*)data;
- (void)maybeCallBotTimeoutBlockWithData:(NSDictionary*)data;
- (void)maybeCallBotRespondedBlockWithData:(NSString*)data;

@end
