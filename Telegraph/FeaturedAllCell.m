//
//  FeaturedAllCell.m
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "FeaturedAllCell.h"
#import "PurchaseItemHelper.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

// GemsCore
#import <GemsCore/GemsLocalization.h>
#import <GemsCore/PaymentRequest.h>

// GemsUI
#import <GemsUI/UserNotifications.h>
#import <GemsUI/iToast+Gems.h>
#import <GemsUI/UIImage+Loader.h>

@interface FeaturedAllCell()
{
    StoreItemData *_data;
}

@end

@implementation FeaturedAllCell

- (void)awakeFromNib {    
    _iv.layer.cornerRadius = 10.0f;
    _iv.layer.masksToBounds = YES;
}

+ (NSString*)cellIdentifier
{
    return @"FeaturedAllCell";
}

- (void)bindCell:(StoreItemData*)data
{
    _data = data;
    
    [_iv sd_setImageWithURL:[NSURL URLWithString:data.iconURL] placeholderImage:[UIImage Loader_gemsImageWithName:@"icon_placeholder"]];

    _btnBuyNow.price = data.price;
    _btnBuyNow.currency = data.currency;
    _btnBuyNow.btn.anchor = CGPointMake(_btnBuyNow.frame.size.width - 10, 0);
    _btnBuyNow.btn.height = 20.0f;
    _btnBuyNow.btn.lbl.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    _btnBuyNow.btn.layer.cornerRadius = 5.0f;
    _btnBuyNow.buyClicked = ^{
        [self purchaseItem];
    };
    [_btnBuyNow setup];
    
    _lblTitle.text = data.title;
    _lblDetails.text = data.categoryStr;
}

+ (CGFloat)cellHeight
{
    return 90.0f;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(_btnBuyNow.btn.currentStateIdx == ASBBuy && [_btnBuyNow hitTest:[self convertPoint:point toView:_btnBuyNow] withEvent:event] == nil)
    {
        [_btnBuyNow.btn displayStateIdx:ASBPrice];
        return NO;
    }
        
    for (UIView* subview in self.subviews ) {
        if ( [subview hitTest:[self convertPoint:point toView:subview] withEvent:event] != nil ) {
            return YES;
        }
    }
    return NO;
}

- (void)purchaseItem
{
    [PurchaseItemHelper purchaseItem:_data completion:^(bool result, NSString *error) {
        if(error) {
            [UserNotifications showUserMessage:error];
            return ;
        }
        
        if(result) {
            [_btnBuyNow.btn displayStateIdx:ASBBoughtDisabled];
            [iToast showInfoToastWithText:GemsLocalized(@"GemsCouponInTransactionScreen")];
        }
    }];
}

@end
