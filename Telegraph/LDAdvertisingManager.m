//
//  LDAdvertisingHelper.m
//  GetGems
//
//  Created by Onizhuk Anton on 3/6/16.
//
//

#import "LDAdvertisingManager.h"
#import "LDAdvertisingChannel.h"

#import "TL/TLMetaScheme.h"
#import "TGTelegramNetworking.h"
#import "TGTelegraph.h"
#import "TGPeerIdAdapter.h"

#import "TGChannelManagementSignals.h"
#import "TLUpdates+TG.h"
#import "TGConversation+Telegraph.h"

#import "TGAppDelegate.h"
#import "TGTelegraphDialogListCompanion.h"

#import <GemsCore/GemsAnalytics.h>


#define extract(dict, key) ([[NSNull null] isEqual:dict[key]] ? nil : dict[key])
#define FIRST_LAUNCH_KEY @"LDAdvetisingManager_cahnnelsInitialized"

@implementation LDAdvertisingManager {
    
    NSMutableDictionary * joinChannelDisposables;

    NSArray <LDAdvertisingChannel *> * advChannels;
    
    NSInteger maxAdLength;
    BOOL promoteKB;
}


#pragma mark Singleton

+ (instancetype)sharedManager {
    
    static id manager = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
    
}

- (id)init {
    if (self = [super init]) {

    } return self;
}


#pragma mark - Public Methods

- (void)setupAdvertising {
    [self fetchAdvertisingConfigurationWithCompletion:^(NSArray <LDAdvertisingChannel *> * channels){
        [self _proceedChannels:channels];
    } error:^(__unused GemsNetworkError * error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setupAdvertising];
        });
    }];
}

- (void)fetchAdvertisingConfigurationWithCompletion:(void(^)(NSArray <LDAdvertisingChannel *> *))completion error:(void(^)(GemsNetworkError *))errorBlock {
    [API getAdverstingConfiguration:^(GNR * respond) {
        if ([respond hasError]) {
            if (errorBlock) {
                errorBlock(respond.error);
            }
            return;
        }
        
        NSDictionary * respondData = respond.rawResponse;
        NSArray * channelDataArray = extract(respondData, @"channels");
        
        if (!channelDataArray || channelDataArray.count == 0) {
            if (errorBlock) errorBlock(nil);
            return;
        }
        
        NSArray * decodedChannels = [LDAdvertisingChannel channelsFromArray:channelDataArray];
        
        if (!decodedChannels || decodedChannels.count == 0) {
            if (errorBlock) errorBlock(nil);
            return;
        }
        
        advChannels = decodedChannels;
        maxAdLength = [extract(respond.rawResponse, @"maxAdLength") integerValue];
        promoteKB = [extract(respond.rawResponse, @"promoteKB") boolValue];
        
        if (completion) {
            completion(advChannels);
        }
        
        // NSLog(@"ONIDZUKA get info:%@", respond.rawResponse);
        
    }];
}

- (NSArray <LDAdvertisingChannel *> *)advertisingChannels {
    return advChannels;
}

- (void)setState:(BOOL)state forChannel:(LDAdvertisingChannel *)channel completion:(void(^)(LDAdvertisingChannel *, NSError *))completion {
    if (channel.status == state) {
        completion(channel, nil);
        return;
    }
    
    void(^report)(id) = ^(id error){
        if (error) {
            completion(channel, error);
        } else {
            channel.status = state;
            [self _reportChannelState:channel completion:completion];
        }
    };
    
    if (state) {
        [self _joinChannel:channel completion:report];
    } else {
        [self _leaveChannel:channel completion:report];
    }
    
}



- (void)didLeaveChannelWithID:(int64_t)conversationId {
    LDAdvertisingChannel * channel = [self _channel:conversationId];
    if (channel && channel.status == YES) {
        channel.status = NO;
        [self _reportChannelState:channel completion:nil];
    }
}

- (void)didSelectConversation:(TGConversation *)conversation {
    LDAdvertisingChannel * channel = [self _channel:conversation.conversationId];
    if (channel) {
        channel.conversation = conversation;
        [self _reportLastMessageFromChannel:channel];
    }
}

- (void)goingToLogout {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FIRST_LAUNCH_KEY];
}

#pragma mark - Private Methods

- (LDAdvertisingChannel *)_channel:(int64_t)conversationId {
    for (LDAdvertisingChannel * channel in advChannels) {
        if (TGPeerIdFromChannelId(channel.telegramChannelId) == conversationId) {
            return channel;
        }
    }
    
    return nil;
}

- (void)_updateWithData:(NSDictionary *)rawData {
    
    maxAdLength = extract(rawData, @"maxAdLength") ? [extract(rawData, @"maxAdLength") integerValue] : maxAdLength;
    promoteKB = extract(rawData, @"promoteKB") ? [extract(rawData, @"promoteKB") boolValue] : promoteKB;
    
    NSArray * channelsRawArray = extract(rawData, @"channels");
    if (!channelsRawArray || channelsRawArray.count == 0) return;
   
    NSMutableArray * decodedChannels = [[LDAdvertisingChannel channelsFromArray:channelsRawArray] mutableCopy];
    if (!decodedChannels || decodedChannels.count == 0)return;
    
    NSMutableArray * newAdvChannels = [NSMutableArray new];
    
    for (LDAdvertisingChannel * channel in decodedChannels) {
        LDAdvertisingChannel * prevChannel = nil;
        for (LDAdvertisingChannel * prev in advChannels) {
            if (prev.telegramChannelId == channel.telegramChannelId) {
                prevChannel = prev;
                break;
            }
        }
        
        if (prevChannel) {
            [newAdvChannels addObject:prevChannel];
            [prevChannel updateData:channel];
        } else {
            [newAdvChannels addObject:channel];
        }
    }
    
    advChannels = [newAdvChannels copy];
    
}



- (void)_proceedChannels:(NSArray *)channels {
    BOOL firstLaunch = [self _firstLaunch];
    
    if (firstLaunch) {
        NSMutableArray * reportJoining = [NSMutableArray new];
        for (LDAdvertisingChannel * channel in channels) {
            if (channel.status == NO) {
                channel.status = YES;
                [reportJoining addObject:channel];
            }
            
            [self _joinChannel:channel completion:nil];
        }
        
        //if there are channels, we forced to join, need to update server side
        if (reportJoining.count > 0) {
            // no need to block main thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                while (reportJoining.count > 0) {
                    LDAdvertisingChannel * channel = [reportJoining lastObject];
                    
                    __block dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                    __block BOOL reqComplete = NO;
                    
                    [self _reportChannelState:channel completion:^(__unused LDAdvertisingChannel * updatedChannel, NSError * error) {

                        CGFloat waitTime;
                        if (error) {
                            waitTime = 3.0;
                        } else {
                            [reportJoining removeLastObject];
                            waitTime = 0.5;
                        }
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            reqComplete = YES;
                            dispatch_semaphore_signal(sema);
                        });
                    }];
                    
                    NSInteger retryCount = 0;
                    while (!reqComplete && retryCount < 10) {
                        retryCount += 1;
                        dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
                    }
                }
            });
        }
    } else {
        for (LDAdvertisingChannel * channel in channels) {
            if (channel.status == YES) {
                [self _joinChannel:channel completion:nil];
            }
            if (channel.status == NO) {
                //[self _leaveChannel:channel completion:nil];
            }
        }
    }
}

- (BOOL)_firstLaunch {
    BOOL launchedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:FIRST_LAUNCH_KEY];
    if (launchedBefore) {
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_LAUNCH_KEY];
    return YES;
}


- (void)_joinChannel:(LDAdvertisingChannel *)channel completion:(void(^)(id))completion {
    
    SMetaDisposable * disposable = [self _joinChannelDisposable:channel];
    
    [disposable setDisposable:[[self signal_joinChannel:channel] startWithNext:nil error:completion completed:^{
//        [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion dialogListReady];
//        [self _updateDialogListWithAdding:channel.conversation];
        
        if (completion) {
            completion(nil);
        }
    }]];
}

- (void)_leaveChannel:(LDAdvertisingChannel *)channel completion:(void(^)(id))completion {
    
    int64_t conversationId = TGPeerIdFromChannelId(channel.telegramChannelId);
    TGConversation * conversation = [TGDatabaseInstance() loadChannels:@[@(conversationId)]][@(conversationId)];

    if (conversation) {
        [TGAppDelegateInstance.rootController.dialogListController.dialogListCompanion deleteItem:conversation animated:false];
    }
    
    if (completion) {
        completion(nil);
    }
    
    
}

- (SMetaDisposable *)_joinChannelDisposable:(LDAdvertisingChannel *)channel {
    if (!joinChannelDisposables) {
        joinChannelDisposables = [[NSMutableDictionary alloc] init];
    }
    
    NSNumber * key = [NSNumber numberWithLong:channel.telegramChannelId];
    SMetaDisposable * disposable = joinChannelDisposables[key];
    
    if (disposable) {
        [disposable dispose];
    }
    
    disposable = [[SMetaDisposable alloc] init];
    joinChannelDisposables[key] = disposable;

    
    return disposable;
    
    
}

- (void)_reportChannelState:(LDAdvertisingChannel *)channel completion:(void(^)(LDAdvertisingChannel *, NSError *))completion {
    [API setUserAdChannelStatus:[channel compileDictionaryWithUser:TGTelegraphInstance.clientUserId] respond:^(GNR *respond) {
        if ([respond hasError]) {
            // NSLog(@"ONIDZUKA setChannelStatus%d Error: %@", channel.status, respond.error.localizedError);
            if (completion) {
                completion(nil, respond.error.NSError);
            }
            return;
        }
        
        [self _updateWithData:respond.rawResponse];
        
        LDAdvertisingChannel * newChannel = [self _channel:TGPeerIdFromChannelId(channel.telegramChannelId)]; //just in case it's not the same object anymore
        [self _analyticsReportForChannel:newChannel];
        
        if (completion) {
            completion(newChannel, nil);
        }
        
    }];
}

- (void)_reportLastMessageFromChannel:(LDAdvertisingChannel *)channel {
    TGConversation * conversation = channel.conversation;
    
    [API postAdsSeenByUserOnChannel:channel.channelId messageId:conversation.maxReadMessageId respond:nil];

}

- (void)_analyticsReportForChannel:(LDAdvertisingChannel *)channel {
    NSDictionary * channelData = @{@"channel" : [channel compileDictionaryWithUser:TGTelegraphInstance.clientUserId]};
    
    if (channel.status) {
        [GemsAnalytics track:AdChannelSubscribed args:channelData];
    } else {
        [GemsAnalytics track:AdChannelUnsubscribed args:channelData];
    }
}



#pragma mark - Telegram API Signals


- (SSignal *)signal_resolveChatName:(NSString *)name completion:(SSignal *(^)(TLcontacts_ResolvedPeer *))completion{
    
    TLRPCcontacts_resolveUsername$contacts_resolveUsername *req = [[TLRPCcontacts_resolveUsername$contacts_resolveUsername alloc] init];
    req.username = name;
    
    return [[[TGTelegramNetworking instance] requestSignal:req] mapToSignal:^SSignal *(TLcontacts_ResolvedPeer * resolvedPeer) {
        if (completion) {
            return completion(resolvedPeer);
        }
        return [SSignal complete];
    }];
}



- (SSignal *)signal_joinChannel:(LDAdvertisingChannel *)channel {
    return [self signal_resolveChatName:channel.chatId completion:^SSignal *(TLcontacts_ResolvedPeer * resolvedPeer) {
        if (![resolvedPeer.peer isKindOfClass:[TLPeer$peerChannel class]] ||
            ((TLPeer$peerChannel *)resolvedPeer.peer).channel_id != channel.telegramChannelId ||
            resolvedPeer.chats.count != 1)
        {
            return [SSignal fail:nil];
        }
        
        TGConversation * conv = [[TGConversation alloc] initWithTelegraphChatDesc:[resolvedPeer.chats firstObject]];
        channel.conversation = conv;
        
        return [[TGChannelManagementSignals addChannel:conv] mapToSignal:^SSignal *(__unused id next) {
            return [TGChannelManagementSignals joinTemporaryChannel:conv.conversationId];
        }];
    }];
    
}













@end
