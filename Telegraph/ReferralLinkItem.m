//
//  ReferralLinkItem.m
//  GetGems
//
//  Created by alon muroch on 5/10/15.
//
//

#import "ReferralLinkItem.h"

@interface ReferralLinkItem()
{
    NSString *_link;
    UIImage *_icon;
    SEL _action;
}

@end

@implementation ReferralLinkItem

- (instancetype)initWithReferralLink:(NSString*)link icont:(UIImage*)icon action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        _link = link;
        _action = action;
        _icon = icon;
    }
    return self;
}

- (Class)itemViewClass
{
    return [ReferralLinkItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 45);
}

- (void)itemSelected:(id)actionTarget
{
    if (_action != NULL && [actionTarget respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

- (void)bindView:(ReferralLinkItemView *)view
{
    [super bindView:view];
    
    [view setLink:_link];
    [view.icon setImage:_icon];
}

- (void)unbindView
{
    [super unbindView];
}

@end
