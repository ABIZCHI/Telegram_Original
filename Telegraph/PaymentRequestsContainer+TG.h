//
//  PaymentRequestsContainer+TG.h
//  GetGems
//
//  Created by alon muroch on 9/5/15.
//
//

#import "PaymentRequestsContainer.h"

@interface PaymentRequestsContainer (TG)

+ (PaymentRequestContext)TG_paymentContext:(int64_t)conversationId;

+ (PaymentRequestsContainer*)TG_container:(int64_t)conversationId;

@end
