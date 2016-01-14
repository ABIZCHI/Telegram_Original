//
//  ReferralInfoHeaderView.m
//  GetGems
//
//  Created by alon muroch on 6/3/15.
//
//

#import "TxInfoHeaderView.h"
#import "TGGemsWallet.h"
#import "UILabel+ShortenFormating.h"

@interface TxInfoHeaderView()
{

}
@end


@implementation TxInfoHeaderView

- (void)hideInfoView
{
    _infoViewContainerTopContraint.constant = - 70.0f;
    _infoViewContainer.alpha = 0.0f;
    
    [super layoutIfNeeded];
}

- (void)loadInfo
{
    _lblTitle.text = GemsLocalized(@"GemsReferrals");
    [_lblCntReferrals setShortenFormattedNumber:@([TGGemsWallet sharedInstance].cntReferrals)];
    [_lblRewards setShortenFormattedNumber:@([TGGemsWallet sharedInstance].gemsEarned)];
}

- (void)moveInfoViewContainerToPlace:(CGFloat)percent
{
    CGFloat fullTravel = 70.0f;
    CGFloat toTravel = fullTravel * percent;
    
    CGFloat toSet = -fullTravel + toTravel;
    _infoViewContainerTopContraint.constant = toSet;
    
    _infoViewContainer.alpha = percent;
    
    [super layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

@end
