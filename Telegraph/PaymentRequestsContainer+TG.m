//
//  PaymentRequestsContainer+TG.m
//  GetGems
//
//  Created by alon muroch on 9/5/15.
//
//

#import "PaymentRequestsContainer+TG.h"
#import "GemsModernConversationControllerHelper.h"

@implementation PaymentRequestsContainer (TG)

+ (PaymentRequestContext)TG_paymentContext:(int64_t)cid
{
    if(GroupConversation(cid))
    {
        return PaymentRequestGroup;
    }
    return PaymentRequestSingle;
}

+ (PaymentRequestsContainer*)TG_container:(int64_t)conversationId
{
    return [[PaymentRequestsContainer alloc] initWithContextType:[self TG_paymentContext:conversationId]];
}

@end
