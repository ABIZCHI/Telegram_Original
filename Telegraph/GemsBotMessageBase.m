//
//  GemsBotPayloadBase.m
//  GetGems
//
//  Created by alon muroch on 5/20/15.
//
//

#import "GemsBotMessageBase.h"
#import "TGDatabase.h"
#import "TGTelegramNetworking.h"
#import "GemsBotErrorMessage.h"

//GemsCore
#import <GemsCore/CryptoUtils.h>
#import <GemsCore/GemsLocalization.h>

@implementation GemsBotMessageBase

+ (id)processMesasge:(NSString*)msg
{
    NSArray *compenents = [msg componentsSeparatedByString:@" "];
    if(compenents.count == 1) { // returned an cmpty payload
        GemsBotErrorMessage *ret = [GemsBotErrorMessage new];
        ret.localizedMsg = GemsLocalized(@"GemsSomethingWentWrong");
        return ret;
    }
    
    if(compenents.count == 2)
    {
        NSString *base58Encoded = compenents[1];
        NSDictionary *payload = [base58Encoded base58ToDictionary];
        
        if([payload[@"success"] boolValue]) return nil;
        
        GemsBotErrorMessage *ret = [GemsBotErrorMessage new];
        ret.localizedMsg = payload[@"message"];
    }
    
    return nil;
}

- (TGPreparedTextMessage*)msg
{
    TGPreparedTextMessage *preparedMsg = [[TGPreparedTextMessage alloc] initWithText:[self generateText] replyMessage:nil disableLinkPreviews:true parsedWebpage:nil];
    preparedMsg.messageLifetime = 120;
    if (preparedMsg.randomId == 0)
    {
        int64_t randomId = 0;
        arc4random_buf(&randomId, sizeof(randomId));
        preparedMsg.randomId = randomId;
    }
    
    if (preparedMsg.mid == 0)
        preparedMsg.mid = [[TGDatabaseInstance() generateLocalMids:1][0] intValue];
    
    preparedMsg.date = (int)[[TGTelegramNetworking instance] approximateRemoteTime];
    
    return preparedMsg;
}

- (NSString*)generateText
{
    return nil;
}

- (BOOL)isValid
{
    return YES;
}

@end
