//
//  SinglePinCodeView.h
//  GetGems
//
//  Created by alon muroch on 7/15/15.
//
//

#import "GemsPinCodeView.h"
#import "PaymentRequestsContainer.h"
#import "PaymentRequest.h"

@interface SinglePinCodeView : GemsPinCodeView

- (void)authenticatePinhash:(NSString*)pinhash forPaymentRequests:(PaymentRequestsContainer*)prContainer completion:(PinCodeBlock)completion;

@end
