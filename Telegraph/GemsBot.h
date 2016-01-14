//
//  GemsBot.h
//  GetGems
//
//  Created by alon muroch on 5/20/15.
//
//

#import <Foundation/Foundation.h>
#import "GemsBotMessageBase.h"
#import "GemsBotConfiguration.h"
#import "TGPreparedTextMessage.h"
#import "TGTelegraph.h"
#import "ASHandle.h"

@interface GemsBot : NSObject <ASWatcher>

+ (instancetype)sharedInstance;

@property (nonatomic, strong) ASHandle *actionHandle;

- (void)dispatchBotMessage:(GemsBotMessageBase *)botMsg bot:(GemsBotConfiguration *)bot;
- (void)maybeAddBot:(GemsBotConfiguration*)bot toContactsWithCompletion:(void (^)(void))completion;

@end

