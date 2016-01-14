//
//  GemsBot.m
//  GetGems
//
//  Created by alon muroch on 5/20/15.
//
//

#import "GemsBot.h"
#import "TGTelegraph.h"
#import "SGraphObjectNode.h"
#import "TGPhonebookContact.h"
#import "TGSynchronizeContactsActor.h"
#import "TGTelegraph.h"

// GemsCore
#import <GemsCore/Macros.h>

@interface GemsBot()
{
    GemsBotConfiguration *_currentlySendingBot;
    GemsBotMessageBase *_currentBotMessage;
    NSTimer *_timeoutTimer;
}

@end

@implementation GemsBot

// singleton
+ (instancetype)sharedInstance
{
    static GemsBot *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GemsBot alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if(self) {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
    }
    return self;
}

#pragma mark - utils

- (void)maybeAddBot:(GemsBotConfiguration*)bot toContactsWithCompletion:(void (^)(void))completion
{
    if([bot inContacts] || ![self canProcessBotRequest:bot]) {
        if(completion)
            completion();
        return;
    }
    
    NSLog(@"adding bot %@ with phonenumber %@ to contacts...", bot.telegramUserName, bot.phoneNumber);
    _currentlySendingBot = bot;
    
    _currentlySendingBot.botAddedToContacts = ^(BOOL result) {
        NSLog(@"added bot %@ with phonenumber %@ to contacts", bot.telegramUserName, bot.phoneNumber);
        if(completion)
            completion();
    };
    
    TGPhonebookContact *phonebookContact = [[TGPhonebookContact alloc] init];
    phonebookContact.firstName = bot.telegramUserName;
    phonebookContact.phoneNumbers = @[[[TGPhoneNumber alloc] initWithLabel:[[TGSynchronizeContactsManager phoneLabels] lastObject] number:bot.phoneNumber]];
    
    static int actionId = 0;
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/synchronizeContacts/(%d,%d,addContactLocal)", TGTelegraphInstance.clientUserId, actionId++] options:[NSDictionary dictionaryWithObjectsAndKeys:phonebookContact, @"contact", [[NSNumber alloc] initWithInt:bot.tgID], @"uid", nil] watcher:self];
}

#pragma mark - Sending messages

- (void)dispatchBotMessage:(GemsBotMessageBase *)botMsg bot:(GemsBotConfiguration *)bot
{
    if(![self canProcessBotRequest:bot]) return;
    [bot prepareBotWithCompletion:^{
        [[GemsBot sharedInstance] maybeAddBot:bot toContactsWithCompletion:^{
            
            _currentBotMessage = botMsg;
            
            TGPreparedTextMessage *message = [botMsg msg];
            
            if (message == nil)
            {
                NSLog(@"***** Failed to generate message from prepared message ***** ");
                return;
            }
            
            NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                             @"preparedMessage": message
                                                                                             }];
            [options addEntriesFromDictionary:[bot optionsForMessageActions]];
            NSDictionary *preparedAction = @{
                                             @"action": [bot messagePathForMessageId:message.mid],
                                             @"options": options
                                             };
            [[GemsBot sharedInstance] dispatchPreparedAction:preparedAction ForBot:bot];
        }];
    }];
}

- (void)dispatchPreparedAction:(NSDictionary*)action ForBot:(GemsBotConfiguration*)bot
{
    NSLog(@"dispatching a msg to gems bot \n%@", action);
    
    _currentlySendingBot = bot;
    
    [ActionStageInstance() watchForPath:@"/tg/conversations" watcher:self];
    [ActionStageInstance() requestActor:action[@"action"] options:action[@"options"] watcher:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:bot.timeoutInSeconds
                                                                             target:self
                                                                           selector:@selector(timeoutBotRequest)
                                                                           userInfo:nil
                                                                            repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timeoutTimer forMode:NSRunLoopCommonModes];
    });
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if(!_currentlySendingBot)return;
    
    if ([path hasPrefix:[_currentlySendingBot messagePathPrefix]])
    {
        if ([messageType isEqualToString:@"messageAlmostDelivered"])
        {
            // delivered
            NSLog(@"Bot messageAlmostDelivered");
            [_currentlySendingBot maybeCallMessageDeliveryCompletionBlockWithData:message];
        }
        else if ([messageType isEqualToString:@"messageDeliveryFailed"])
        {
            NSLog(@"Bot messageDeliveryFailed, tries remaining %d", _currentlySendingBot.consecutiveTries--);
            if(_currentlySendingBot.consecutiveTries > 0)
            {
                [self dispatchBotMessage:_currentBotMessage bot:_currentlySendingBot];
            }
            else {
                [_currentlySendingBot maybeCallMessageDeliveryCompletionBlockWithError:@"Could not deliver message to Gems bot"];
                [self clearBot];
            }
        }
        else if ([messageType isEqualToString:@"messageProgress"])
        {
            NSLog(@"Bot messageProgress");
        }
    }
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    NSLog(@"Received msg to Gem bot, processing ....\n%@", resource);
    if(!_currentlySendingBot) {
        NSLog(@"Bot is nil, not processing message %@", resource);
        return;
    }
    
    if ([path isEqualToString:@"/tg/conversations"]) {
        NSMutableArray *conversations = [((SGraphObjectNode *)resource).object mutableCopy];
        for(TGConversation *c in conversations) {
            if(c.conversationId == _currentlySendingBot.tgID) {
                
                NSLog(@"Received answer form bot, canceling timeout timer");
                if(_timeoutTimer) {
                    [_timeoutTimer invalidate];
                    _timeoutTimer = nil;
                }
                
                [_currentlySendingBot maybeCallBotRespondedBlockWithData:c.text];
                
                int tgid = _currentlySendingBot.tgID;
                BOOL deleteBotConversationWhenFinished = _currentlySendingBot.deleteBotConversationWhenFinished;
                [self clearBot];
                if(deleteBotConversationWhenFinished) {
                    [self deleteBotConversationWhenFinishedWithTgId:tgid];
                }
            }
        }
    }
    
    NSRange r = [path rangeOfString:@"/clearHistory/"];
    if(r.location != NSNotFound)
    {
        NSLog(@"Cleared bot history");
        
        // continue to delete the conversation
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasSuffix:@"addContactLocal)"])
    {
        [_currentlySendingBot maybeCallBotAddedToContacts:Successfull];
    }
}

- (void)timeoutBotRequest
{
    if(!_currentlySendingBot)return;
    
    NSLog(@"Bot timeout");
    
    [_currentlySendingBot maybeCallBotTimeoutBlockWithData:@{@"success": @(0),
                                                            @"message": @"Bot timeout"}];
    
    int tgid = _currentlySendingBot.tgID;
    BOOL deleteBotConversationWhenFinished = _currentlySendingBot.deleteBotConversationWhenFinished;
    [self clearBot];
    if(deleteBotConversationWhenFinished) {
        [self deleteBotConversationWhenFinishedWithTgId:tgid];
    }
}

- (void)clearBot
{
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
    _currentlySendingBot = nil;
    _currentBotMessage = nil;
    [ActionStageInstance() removeWatcher:self];
}

- (void)deleteBotConversationWhenFinishedWithTgId:(int)tgid
{
    _currentlySendingBot.deleteBotConversationWhenFinished = NO; // to not repeat the action
    [self clearBotHistoryWithTgId:tgid];
    [self deleteBotConversationWithTgId:tgid];
}

- (void)clearBotHistoryWithTgId:(int)tgid
{
    int actionId = 0;
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%d)/clearHistory/(dialogList%d)", tgid, actionId++] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:tgid] forKey:@"conversationId"] watcher:self];
}

- (void)deleteBotConversationWithTgId:(int)tgid
{
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%d)/delete", tgid] options:[NSDictionary dictionaryWithObject:[NSNumber numberWithLongLong:tgid] forKey:@"conversationId"] watcher:self];
}

- (BOOL)canProcessBotRequest:(GemsBotConfiguration*)bot
{
    return (_currentlySendingBot && _currentlySendingBot.tgID == bot.tgID) || !_currentlySendingBot;
}

@end
