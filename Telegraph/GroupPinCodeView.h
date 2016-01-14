//
//  GroupPinCodeView.h
//  GetGems
//
//  Created by alon muroch on 7/14/15.
//
//

#import "GemsPinCodeView.h"
#import "PaymentRequestsContainer.h"

typedef enum
{
    GroupPinCodeDivide = 1,
    GroupPinCodeEach = 2
}GroupPinCodeType;

@interface PaymentRequestsContainer (GroupPinCodeView)

@property (nonatomic, assign) GroupPinCodeType groupPinCodeType;

@end

@interface GroupPinCodeView : GemsPinCodeView <GemsAlertViewDelegate>

- (void)authenticatePinhash:(NSString*)pinhash
         forPaymentRequests:(PaymentRequestsContainer*)prContainer
                       type:(GroupPinCodeType)type
                 completion:(PinCodeBlock)completion;
- (void)confirmPaymentRequests:(PaymentRequestsContainer*)prContainer
                          type:(GroupPinCodeType)type
                    completion:(PinCodeBlock)completion;

- (NSArray*)selectedPaymentRequests;

@end
