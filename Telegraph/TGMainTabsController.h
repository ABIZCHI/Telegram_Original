/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>
#import "TGViewController.h"

GEMS_CLASS_EXTERN
@protocol TGTabBarDelegate <NSObject>

- (void)tabBarSelectedItem:(int)index;

@end

GEMS_CLASS_EXTERN
@interface TGTabBar : UIView

@property (nonatomic, weak) id<TGTabBarDelegate> tabDelegate;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *stripeView;

@property (nonatomic, strong) NSMutableArray *buttonViews;
@property (nonatomic, strong) NSMutableArray *labelViews;

@property (nonatomic, strong) UIView *unreadBadgeContainer;
@property (nonatomic, strong) UIImageView *unreadBadgeBackground;
@property (nonatomic, strong) UILabel *unreadBadgeLabel;

@property (nonatomic) int selectedIndex;

GEMS_METHOD_EXTERN - (UILabel *)createTabLabelWithText:(NSString *)text;
GEMS_METHOD_EXTERN - (CGFloat)iconVerticalOffset;
GEMS_METHOD_EXTERN - (CGFloat)labelVerticalOffset;

@end

@interface TGMainTabsController : UITabBarController <TGViewControllerNavigationBarAppearance>

GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGTabBar *customTabBar;

- (void)setUnreadCount:(int)unreadCount;

- (void)localizationUpdated;

GEMS_METHOD_EXTERN - (CGFloat)tabBarHeight;

@end