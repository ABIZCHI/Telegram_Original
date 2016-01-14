//
//  GemsModernConversationInputTextPanel.h
//  GetGems
//
//  Created by alon muroch on 3/18/15.
//
//

#import "TGModernConversationInputTextPanel.h"
#import "HPGrowingTextView.h"
#import "PaymentRequest.h"
#import "PaymentRequestsContainer.h"
#import "TGViewController.h"

@interface GemsModernConversationInputTextPanel : TGModernConversationInputTextPanel <HPGrowingTextViewDelegate>

@property(nonatomic, strong)  PaymentRequestsContainer *prContainer;
@property(nonatomic) int64_t conversationID;

@property (nonatomic, weak) TGViewController *containingViewController;

- (void)setText:(NSString*)text animated:(BOOL)animated;

@end
