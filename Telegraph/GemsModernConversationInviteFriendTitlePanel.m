//
//  GemsModernConversationInviteFriendTitlePanel.m
//  GetGems
//
//  Created by alon muroch on 5/3/15.
//
//

#import "GemsModernConversationInviteFriendTitlePanel.h"
#import "TGModernButton.h"
#import "TGBackdropView.h"
#import "TGFont.h"
#import "TGImageUtils.h"
#import "TGAppDelegate.h"
#import "TGNavigationBar.h"
#import "TGDatabase.h"

// GemsUI
#import <GemsUI/GemsAppearance.h>
#import <GemsUI/UIImage+Loader.h>

// GemsCore
#import <GemsCore/GemsLocalization.h>
#import <GemsCore/GemsStringUtils.h>

#define INVITE_FRIEND_PANEL_LAST_SHOWN_KEY @"INVITE_FRIEND_PANEL_LAST_SHOWN_KEY"

@implementation GemsModernConversationInviteFriendTitlePanel

+ (BOOL)enoughTimePassedSinceLastShowedPanelForUser:(int64_t)uid
{
    NSString *conversationSpecificKey = [self conversationSpecificKey:uid];
    NSNumber *lastSeen = [[NSUserDefaults standardUserDefaults] objectForKey:conversationSpecificKey];
    if(!lastSeen)
        return YES;
    
    NSTimeInterval t = [lastSeen doubleValue];
    if((t + 60 * 60 * 24 * 3) < [[NSDate date] timeIntervalSince1970]) // show every 3 days
        return YES;
    return NO;
}

+ (NSString*)conversationSpecificKey:(int64_t)uid
{
    return [NSString stringWithFormat:@"%@_%lld", INVITE_FRIEND_PANEL_LAST_SHOWN_KEY, uid];
}

+ (void)setLastSeenForUser:(int64_t)uid
{
    NSString *conversationSpecificKey = [self conversationSpecificKey:uid];
    [[NSUserDefaults standardUserDefaults] setObject:@([[NSDate date] timeIntervalSince1970]) forKey:conversationSpecificKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)initWithFrame:(CGRect)frame conversationId:(int64_t)uid
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 80.0f)];
    if (self)
    {
        if (!TGBackdropEnabled())
        {
            _backgroundView = [TGBackdropView viewWithLightNavigationBarStyle];
            [self addSubview:_backgroundView];
        }
        else
        {
            UIToolbar *toolbar = [[UIToolbar alloc] init];
            _backgroundView = toolbar;
            [self addSubview:_backgroundView];
        }
        
        TGNavigationController *navController = (TGNavigationController*)TGAppDelegateInstance.rootController.presentedViewController;
        TGNavigationBar *navBar = (TGNavigationBar*)navController.navigationBar;
        UIColor *bgColor = navBar.barBackgroundView.backgroundColor;
        
        _backgroundView.backgroundColor = bgColor;
        
        _stripeLayer = [[CALayer alloc] init];
        _stripeLayer.backgroundColor = UIColorRGB(0xb2b2b2).CGColor;
        [self.layer addSublayer:_stripeLayer];
        
        _actionButton = [[TGModernButton alloc] init];
        _actionButton.adjustsImageWhenDisabled = false;
        _actionButton.adjustsImageWhenHighlighted = false;
        [_actionButton setTitleColor:[GemsAppearance navigationTextColor]];
        _actionButton.titleLabel.font = TGSystemFontOfSize(15);
        [_actionButton addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _actionButton.titleLabel.numberOfLines = 0;
        
        TGUser *user = [TGDatabaseInstance() loadUser:uid];
        NSString *title = [NSString stringWithFormat:@"%@\n%@", _R(GemsLocalized(@"GemsInviteBannerTitle"), @"%1$s", user.firstName), GemsLocalized(@"GemsInviteBannerSubtitle")];
        [_actionButton setTitle:title forState:UIControlStateNormal];
        [self addSubview:_actionButton];
        
        UIImage *closeImage = [UIImage imageNamed:@"ModernConversationTitlePanelClose.png"];
        _closeButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 34, 34)];
        _closeButton.adjustsImageWhenDisabled = false;
        _closeButton.adjustsImageWhenHighlighted = false;
        _closeButton.modernHighlight = true;
        [_closeButton setImage:closeImage forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
        
        [GemsModernConversationInviteFriendTitlePanel setLastSeenForUser:uid];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    _stripeLayer.frame = CGRectMake(0.0f, self.frame.size.height - TGRetinaPixel, self.frame.size.width, TGRetinaPixel);
    _actionButton.frame = CGRectInset(self.bounds, 40.0f, 0.0f);
    
    CGRect closeButtonFrame = _closeButton.frame;
    closeButtonFrame.origin = CGPointMake(self.frame.size.width - 4.0f - TGRetinaPixel - closeButtonFrame.size.width, TGRetinaPixel);
    _closeButton.frame = closeButtonFrame;
}

- (void)actionButtonPressed
{
    if (_action)
        _action();
}

- (void)closeButtonPressed
{
    if (_close)
        _close();
}

@end
