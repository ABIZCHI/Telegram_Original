//
//  GemsModernConversationController.h
//  GetGems
//
//  Created by alon muroch on 3/20/15.
//
//

#import "TGModernConversationController.h"

// GemsUI
#import <GemsUI/GemsNumberPadViewController.h>

@interface ConversationNumberPad : GemsNumberPadViewController

@property (nonatomic, copy) void (^dismissBlock)(void);
@property (nonatomic, copy) void (^completed)(PaymentRequestsContainer *prContainer, NSString *errorString);

@end

@interface GemsModernConversationController : TGModernConversationController <TGModernConversationInputPanelDelegate>

- (instancetype)initWithMessage:(NSString*)message;

@end
