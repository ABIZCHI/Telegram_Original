//
//  SinglePinCodeView.h
//  GetGems
//
//  Created by alon muroch on 7/15/15.
//
//

// GemsUI
#import <GemsUI/GemsPinCodeView.h>

// GemsCore
#import <GemsCore/PaymentRequestsContainer.h>

@interface SinglePinCodeView : GemsPinCodeView

- (void)authenticatePinhash:(NSString*)pinhash forPaymentRequests:(PaymentRequestsContainer*)prContainer completion:(PinCodeBlock)completion;

@end
