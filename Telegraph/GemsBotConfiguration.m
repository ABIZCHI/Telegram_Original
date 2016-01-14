//
//  GemsBotConfiguration.m
//  GetGems
//
//  Created by alon muroch on 5/20/15.
//
//

#import "GemsBotConfiguration.h"
#import "TGUserDataRequestBuilder.h"
#import "TGTelegraph.h"
#import "SGraphObjectNode.h"

@interface GemsBotConfiguration()
{
    void (^_currentPreparationCompletion)();
}
@end

@implementation GemsBotConfiguration

- (instancetype)initWithTelegramUsername:(NSString*)username
{
    self = [super init];
    if(self) {
        _telegramUserName = username;
        _timeoutInSeconds = 10;
        _deleteBotConversationWhenFinished = YES;
        _consecutiveTries = 1;
        
         _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        _currentPreparationCompletion = nil;
    }
    return self;
}

- (void)prepareBotWithCompletion:(void (^)(void))completion
{
    [self completeBotInfoFetchingIfNeededWithCompletion:^{
        [self assertBotUnblockedWithCompletion:^{
            if (completion)
                completion();
            
            _currentPreparationCompletion = nil;
        }];
    }];
}

- (void)completeBotInfoFetchingIfNeededWithCompletion:(void (^)(void))completion
{
    _currentPreparationCompletion = completion;
    [TGTelegraphInstance doSearchContactsByName:_telegramUserName limit:1 completion:^(TLcontacts_Found *result)
     {
         if (result != nil)
         {
             TGUser *u = [[TGUser alloc] initWithTelegraphUserDesc:[result.users firstObject]];
             if(!u.userName) { // bot already in local contacts
                 [TGDatabaseInstance() searchContacts:_telegramUserName ignoreUid:0 searchPhonebook:YES completion:^(NSDictionary *result)
                  {
                      TGUser *u = ((NSArray*)result[@"users"]).firstObject;
                      if(u) {
                          _tgUser = u;
                          _tgID = u.uid;
                          _accessHash = u.phoneNumberHash;
                          [TGUserDataRequestBuilder executeUserObjectsUpdate:@[u]];
                          
                          if(completion)
                              completion();
                          
                          return;
                      }
                      else
                      {
                          if(completion)
                              completion();
                      }
                  }];
                 return ;
             }
             _tgUser = u;
             _tgID = u.uid;
             _accessHash = u.phoneNumberHash;
             [TGUserDataRequestBuilder executeUserObjectsUpdate:@[u]];
             
             if(completion)
                 completion();
         }
     }];
}

- (void)assertBotUnblockedWithCompletion:(void (^)(void))completion
{
    _currentPreparationCompletion = completion;
    
    [ActionStageInstance() watchForPath:@"/tg/blockedUsers" watcher:self];
    [ActionStageInstance() watchForPath:@"/tg/blockedUsers/(force)" watcher:self];
    
    [ActionStageInstance() requestActor:@"/tg/blockedUsers/(force)" options:nil watcher:self];

}

- (BOOL)inContacts
{
    return _tgUser.phoneNumber.length > 0;
}

- (NSDictionary *)optionsForMessageActions
{
    return @{@"conversationId": @(_tgID)};
}

- (NSString *)messagePathForMessageId:(int32_t)mid
{
    return [[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%@)/(%d)", [[NSString alloc] initWithFormat:@"%d", _tgID], mid];
}

- (NSString *)messagePathPrefix
{
    return [[NSString alloc] initWithFormat:@"/tg/sendCommonMessage/(%@)/", [[NSString alloc] initWithFormat:@"%d", _tgID]];
}

- (void)maybeCallMessageDeliveryCompletionBlockWithError:(NSString*)error
{
    if(_sendingCompletionBlock)
        _sendingCompletionBlock(nil, error);
}

- (void)maybeCallMessageDeliveryCompletionBlockWithData:(NSDictionary*)data
{
    if(_sendingCompletionBlock)
        _sendingCompletionBlock(data, nil);
}

- (void)maybeCallBotRespondedBlockWithData:(NSString*)data
{
    if(_botResponseBlock)
        _botResponseBlock(data);
}

- (void)maybeCallBotTimeoutBlockWithData:(NSDictionary*)data
{
    if(_botTimeoutBlock)
        _botTimeoutBlock(data);
}

- (BOOL)maybeCallBotAddedToContacts:(BOOL)result
{
    if(_botAddedToContacts)
        _botAddedToContacts(result);
}

#pragma mark - 
- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path hasPrefix:@"/tg/blockedUsers"])
    {
        id blockedResult = ((SGraphObjectNode *)resource).object;
        
        bool blocked = false;
        
        if ([blockedResult respondsToSelector:@selector(boolValue)])
            blocked = [blockedResult boolValue];
        else if ([blockedResult isKindOfClass:[NSArray class]])
        {
            for (TGUser *user in blockedResult)
            {
                if (user.uid == _tgID)
                {
                    blocked = true;
                    break;
                }
            }
        }
        
        if (blocked) {
            // unblock
            static int actionId = 0;
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/changePeerBlockedStatus/(%d)", actionId++] options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithLongLong:_tgID], @"peerId", @NO, @"block", nil] watcher:self];
        }
        
        [ActionStageInstance() removeWatcher:self fromPath:@"/tg/blockedUsers"];
        [ActionStageInstance() removeWatcher:self fromPath:@"/tg/blockedUsers/(force)"];
        
        if (_currentPreparationCompletion)
            _currentPreparationCompletion();
    }
}

//- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
//{
//    if ([path hasPrefix:@"/tg/changePeerBlockedStatus"]) {
//        if (_currentPreparationCompletion)
//            _currentPreparationCompletion();
//    }
//}

@end
