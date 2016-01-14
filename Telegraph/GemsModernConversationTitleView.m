//
//  GemsModernConversationTitleView.m
//  GetGems
//
//  Created by alon muroch on 3/25/15.
//
//

#import "GemsModernConversationTitleView.h"
#import "TGFont.h"

@implementation GemsModernConversationTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.titleLabel.textColor = [GemsAppearance modernConversationTitleColor];
        self.statusLabel.textColor = [GemsAppearance modernConversationStatusColor];
    }
    return self;
}

@end
