//
//  ActionStageStub.m
//  GetGems
//
//  Created by alon muroch on 5/17/15.
//
//

#import "ActionStageStub.h"
#import "SGraphObjectNode.h"
#import "ActionStage.h"
#import "TGSignInRequestBuilder.h"
#import "TGSignUpRequestBuilder.h"

@implementation ActionStageStub

+ (BOOL)stubActionCallForPath:(NSString*)path  watcher:(id<ASWatcher>)watcher
{
#if SIMULATE_TELEGRAM_SERVER_RESPONSE
    if([path rangeOfString:@"/tg/service/auth/sendCode/"].location != NSNotFound) {
        SGraphObjectNode *res = [[SGraphObjectNode alloc] initWithObject:@{@"phoneCodeHash": @"c78fa741b374846c03",
                                                                           @"messageSentToTelegram": @"0" // @"0" // uncomment if you want to simulte sms sending
                                                                           }];
        [watcher actorCompleted:ASStatusSuccess path:path result:res];
        return YES;
    }
    
    if([path rangeOfString:@"/tg/service/auth/signIn/"].location != NSNotFound) {
//        SGraphObjectNode *res = [[SGraphObjectNode alloc] initWithObject:@{@"activated": @"1"}]; // existing user
//        [watcher actorCompleted:ASStatusSuccess path:path result:res];
        
        [watcher actorCompleted:TGSignInResultNotRegistered path:path result:nil]; // to simulate new user
        
        return YES;
    }
    
    if([path rangeOfString:@"/tg/service/auth/signUp/"].location != NSNotFound) {
        SGraphObjectNode *res = [[SGraphObjectNode alloc] initWithObject:@{@"activated": @"1" // @"0"
                                                                           }];
        [watcher actorCompleted:ASStatusSuccess path:path result:res];
        return YES;
    }
    
    if([path rangeOfString:@"/tg/activation"].location != NSNotFound) {
        SGraphObjectNode *res = [[SGraphObjectNode alloc] initWithObject:@"1" /* @"0" */];
        [watcher actorCompleted:ASStatusSuccess path:path result:res];
        return YES;
    }
    
    if([path rangeOfString:@"/tg/service/auth/signUp/"].location != NSNotFound) {
//        SGraphObjectNode *res = [[SGraphObjectNode alloc] initWithObject:@"1" /* @"0" */];
//        [watcher actorCompleted:ASStatusSuccess path:path result:res];
        
        SGraphObjectNode *res = [[SGraphObjectNode alloc] initWithObject:@(TGSignUpResultInvalidToken)];
        [watcher actorCompleted:ASStatusSuccess path:path result:res];
        return YES;
    }
    
    return  NO;
#else
    return NO;
#endif
    
}

@end
