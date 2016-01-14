//
//  GemsModernConversationInviteFriendTitlePanel.h
//  GetGems
//
//  Created by alon muroch on 5/3/15.
//
//

#import "TGModernConversationTitlePanel.h"
#import "TGModernButton.h"

@interface GemsModernConversationInviteFriendTitlePanel : TGModernConversationTitlePanel
{
    CALayer *_stripeLayer;
    UIView *_backgroundView;
    
    TGModernButton *_actionButton;
    TGModernButton *_closeButton;
}

+ (BOOL)enoughTimePassedSinceLastShowedPanelForUser:(int64_t)uid;

- (id)initWithFrame:(CGRect)frame conversationId:(int64_t)uid;
@property (nonatomic, copy) void (^action)();
@property (nonatomic, copy) void (^close)();

@end
