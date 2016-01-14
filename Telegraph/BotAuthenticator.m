//
//  BotAuthenticator.m
//  GetGems
//
//  Created by alon muroch on 8/18/15.
//
//

#import "BotAuthenticator.h"

#import "GemsBot.h"
#import "GemsBotErrorMessage.h"
#import "GemsBotAuthenticationMsg.h"
#import "TGDialogListCompanion.h"
#import "GemsDialogListController.h"
#import "TGAppDelegate.h"

// networking
#import <GemsNetworking.h>

@interface BotAuthenticator()
{
    NSString *_deviceAuth, *_phoneNumber, *_ver;
}

@end

@implementation BotAuthenticator

- (instancetype)initWithDeviceAuth:(NSString*)deviceAuth phoneNumber:(NSString*)phoneNumber ver:(NSString*)ver
{
    self = [super init];
    if(self) {
        _deviceAuth = deviceAuth;
        _phoneNumber = phoneNumber;
        _ver = ver;
    }
    return self;
}

- (void)authenticate:(AuthenticationBlock)completion
{
    BOOL isTgActivated = TGTelegraphInstance.clientIsActivated;
    if(!isTgActivated)
    {
        NSLog(@"Telegram is not activated, can't authenticate with TG Bot");
        if (completion) {
            completion([NSError errorWithDomain:@"Error" code:1 userInfo:@{@"message" : @"Telegram Client is not activated",
                                                                           @"status" : kGeneralAuthExceptionPleaseWait}],
                       nil, nil, NO);
        }
        return;
    }
    
    [API getAvailableTelebots:^(GemsNetworkRespond *respond) {
        if([respond hasError]) {
            if(completion)
                completion([respond.error NSError], nil, nil, false);
            return ;
        }

        if(!respond.rawResponse[@"telebot"]) {
            if (completion) {
                completion([NSError errorWithDomain:@"Error" code:1 userInfo:@{@"message" : @"Not available registration bots, please try again later."}], nil, nil, NO);
            }
            return;
        }
        
        // send authentication request via Telebot
        GemsBotConfiguration *bot = [[GemsBotConfiguration alloc] initWithTelegramUsername:respond.rawResponse[@"telebot"]];
        bot.consecutiveTries = 5;
#if !RELEASE_CERT
        bot.deleteBotConversationWhenFinished = NO;
#endif
        bot.botResponseBlock = ^(NSString *data) {
            [self hideBotFromConversations:bot.tgID];
            
            GemsBotErrorMessage *error = [GemsBotMessageBase processMesasge:data];
            if(error)
            {
                if(completion)
                    completion([NSError errorWithDomain:@"BotError" code:0 userInfo:@{@"message" : error.localizedMsg}],
                               nil,
                               nil,
                               NO);
                return ;
            }
            
            GemsBotAuthenticationMsg *botResponse = [GemsBotAuthenticationMsg processMesasge:data];
            if(![botResponse isValid])
            {
                if(completion)
                    completion([NSError errorWithDomain:@"BotError" code:0 userInfo:@{@"message" : @"Could not authenticate user"}], nil,
                        nil,
                        NO);
                return ;
            }
            
            if(completion)
                completion(nil, botResponse.jwtToken, botResponse.gemsId, botResponse.wasRegistering);
        };
        bot.botTimeoutBlock = ^(NSDictionary *data) {
            [self hideBotFromConversations:bot.tgID];
            
            if (completion) {
                completion([NSError errorWithDomain:@"Error" code:1 userInfo:@{@"message" : @"Registration bot timeout"}], nil, nil, NO);
            }
        };
        bot.sendingCompletionBlock = ^(NSDictionary *data, NSString *error) {
            [self hideBotFromConversations:bot.tgID];
            
            // call completion only on error
            if(error) {
                if (completion) {
                    completion([NSError errorWithDomain:@"Error" code:1 userInfo:@{@"message" : error}], nil, nil, NO);
                }
            }
        };
        
        GemsBotAuthenticationMsg *msg = [[GemsBotAuthenticationMsg alloc] initWithDeviceAuth:_deviceAuth phoneNumber:_phoneNumber ver:_ver];
        [[GemsBot sharedInstance] dispatchBotMessage:msg bot:bot];
    }];
}

- (void)hideBotFromConversations:(int32_t)botId {
    [TGDialogListCompanion hideConversationWithId:botId];
    [TGAppDelegateInstance.rootController.dialogListController.tableView reloadData];
}

@end
