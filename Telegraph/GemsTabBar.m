//
//  GemsTabBar.m
//  GetGems
//
//  Created by alon muroch on 3/15/15.
//
//

#import "GemsTabBar.h"
#import "TGImageUtils.h"

@implementation GemsTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        // add wallet tab before the settings tab
        UIImageView *walletIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabIconGemsWallet"] highlightedImage:[UIImage imageNamed:@"TabIconGemsWallet_Highlighted"]];
        [self addSubview:walletIcon];
        [self.buttonViews insertObject:walletIcon atIndex:([self.buttonViews count] - 1)];
        
        UIImageView *appStoreIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabIconStore"] highlightedImage:[UIImage imageNamed:@"TabIconStore_Highlighted"]];
        [self addSubview:appStoreIcon];
        [self.buttonViews insertObject:appStoreIcon atIndex:([self.buttonViews count] - 1)];
        
        NSArray *titles = @[GemsLocalized(@"Contacts.TabTitle"),
                            GemsLocalized(@"DialogList.TabTitle"),
                            GemsLocalized(@"GemMainTitleWallet"),
                            GemsLocalized(@"GemsStore"),
                            GemsLocalized(@"Settings.TabTitle")];
        
        // remove lables added in super
        for (UILabel *v in self.labelViews)
        {
            [v removeFromSuperview];
        }
        
        // re-add correct lables
        self.labelViews = [[NSMutableArray alloc] init];
        for (NSString *title in titles)
        {
            UILabel *label = [self createTabLabelWithText:title];
            [self addSubview:label];
            [self.labelViews addObject:label];
        }

    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    int numberOfTabs = [self.buttonViews count];
    
    UITouch *touch = [touches anyObject];
    int index = MAX(0, MIN((int)self.buttonViews.count - 1, (int)([touch locationInView:self].x / (self.frame.size.width / numberOfTabs))));
    [self setSelectedIndex:index];
    
    __strong id<TGTabBarDelegate> delegate = self.tabDelegate;
    [delegate tabBarSelectedItem:index];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize viewSize = self.frame.size;
    
    self.backgroundView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    CGFloat stripeHeight = TGIsRetina() ? 0.5f : 1.0f;
    self.stripeView.frame = CGRectMake(0, -stripeHeight, viewSize.width, stripeHeight);
    
    {// tab icons
        
        CGFloat extremeDistanceFactor = 0.7f;
        CGFloat offsetBetweenIcons;
        CGFloat extremesDistance;
        
        CGFloat iconVerticalOffset = [self iconVerticalOffset];
        CGFloat labelVerticalOffset = [self labelVerticalOffset];
        
        // calculate biggest lable
        CGFloat iconWidth = ((UIView*)[self.buttonViews firstObject]).frame.size.width;
        
        offsetBetweenIcons = (viewSize.width - self.buttonViews.count * iconWidth)/ (self.buttonViews.count - 1 + 2 * extremeDistanceFactor);
        extremesDistance = extremeDistanceFactor * offsetBetweenIcons;
        
        int index = -1;
        for (UIView *iconView in self.buttonViews)
        {
            index ++;
            
            // icon
            CGRect frame = iconView.frame;
            frame.origin.x = extremesDistance + (iconWidth + offsetBetweenIcons) * index;
            frame.origin.y = iconVerticalOffset;
            iconView.frame = frame;
            
            // conversation undread icons
            if (index == 1)
            {
                if (self.unreadBadgeContainer != nil)
                {
                    CGRect unreadBadgeContainerFrame = self.unreadBadgeContainer.frame;
                    unreadBadgeContainerFrame.origin.x = frame.origin.x + frame.size.width - 9;
                    unreadBadgeContainerFrame.origin.y = 2;
                    self.unreadBadgeContainer.frame = unreadBadgeContainerFrame;
                }
            }
            
            
            // label
            UILabel *labelView = [self.labelViews objectAtIndex:index];
            [labelView sizeToFit];
            labelView.center = CGPointMake(iconView.center.x, labelView.center.y);
            CGRect rLabel = labelView.frame;
            rLabel.origin.y = labelVerticalOffset;
            labelView.frame = rLabel;
        }
    }
    
}

@end
