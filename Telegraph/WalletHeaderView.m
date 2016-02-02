//
//  WalletTableHeaderView.m
//  GetGems
//
//  Created by alon muroch on 6/8/15.
//
//

#import "WalletHeaderView.h"
#import "TGGemsWallet.h"
#import "TGNavigationBar.h"
#import "TGAppDelegate.h"
#import "SocialSharerHelper.h"

// GemsCore
#import <GemsCore/GemsLocalization.h>
#import <GemsCore/GemsCD.h>
#import <GemsCore/GemsColors.h>
#import <GemsCore/GemsAnalytics.h>
#import <GemsCore/GemsStringUtils.h>

// GemsUI
#import <GemsUI/GemsAppearance.h>
#import <GemsUI/UIImage+Loader.h>
#import <GemsUI/UILabel+ShortenFormating.h>

@interface WalletHeaderView()
{
    SocialSharerHelper *_sharerHelper;
}

@end

@implementation WalletHeaderView

+ (instancetype)new
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"WalletHeaderView" owner:self options:nil];
    return (WalletHeaderView *)[nib objectAtIndex:0];
}

- (void)awakeFromNib
{
    _topContainerView.backgroundColor = [GemsAppearance navigationBackgroundColor];
    
    _sharerHelper = [[SocialSharerHelper alloc] init];
    
    [self setBalancesView];
    [self setupSyncLabel];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setBalancesView
{
    _balancesView.delegate = self;
    [_balancesView clearAll];
    
    BalanceObject *gemsObj = [[BalanceObject alloc] init];
    gemsObj.cryptoSuffix = GemsLocalized(@"Gems");
    gemsObj.currency = _G;
    gemsObj.assetColor = [GemsColors colorWithType:GemsRed];
    gemsObj.assetIcon = [UIImage Loader_gemsImageWithName:@"gem_currency_icon"];
    gemsObj.startingValue = [@([_G balance]) currency_gillosToGems];
    
    if([_B isActive])
    {
        BalanceObject *btcObj = [[BalanceObject alloc] init];
        btcObj.cryptoSuffix = [GemsStringUtils btcSysUnitName];
        btcObj.currency = _B;
        btcObj.assetColor = [GemsColors colorWithType:BitcoinOrange];
        btcObj.startingValue = [@([_B balance]) CD_satoshiToSysUnit];
        
        [_balancesView addBalances:@[gemsObj, btcObj]];

    }
    else {
        [_balancesView addBalances:@[gemsObj]];
    }
}

- (void)updateBalanceToNewGemsBalance:(NSNumber*)newGems newBtc:(NSNumber*)newBtc
{
    [_balancesView refreshCurrency:_G withNewValue:newGems];
    [_balancesView refreshCurrency:_B withNewValue:newBtc];
}

- (IBAction)inviteFriendsPressed:(__unused id)sender {
//    [[_sharerHelper inviteAttachmentSheetWindow] showAnimated:YES completion:NilCompletionBlock];
}

#pragma mark - scrollAnimationEffect
- (void)animateForScrollViewOffset:(CGFloat)offset
{
    // alpha changing
    CGFloat startingOffset = 0;
    CGFloat endOffset = -self.frame.size.height*0.9f;
    if(offset < endOffset)
        offset = endOffset;
    else if(offset > startingOffset)
        offset = startingOffset;
    CGFloat per = fabs(offset / endOffset);
    _balancesView.alpha = 1 - per;
    
    
    // translation
    _outerContainerTopConstraint.constant = -offset*0.8;
}

#pragma mark - BalancesViewDelegate
- (void)chnagedToBalanceView:(BalanceView*)view
{
    // to prevent jumps
    if(!(GEMS.globalSelectedCurrency == view.obj.currency))
    {
        GEMS.globalSelectedCurrency = view.obj.currency;
        [self trackAssetChanged:GEMS.globalSelectedCurrency];
    }
}

- (void)trackAssetChanged:(Currency*)currency
{
    [GemsAnalytics track:AnalyticsAssetChanged args:@{@"origin": @"wallet",
                                                      @"type": [currency symbol]}];
}

#pragma mark - UILabel sync progress
- (void)setupSyncLabel
{
    [_progressBar addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    [_progressBar addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"progress"]) {
        CGFloat progress = [[change objectForKey: NSKeyValueChangeNewKey] floatValue];
        progress *=100;
        _lblProgress.text = [NSString stringWithFormat:@"%@%%", formatDoubleToStringWithDecimalPrecision(progress, 2)];
    }
    
    if ([keyPath isEqualToString:@"hidden"]) {
        BOOL isHidden = [[change objectForKey: NSKeyValueChangeNewKey] boolValue];
        _lblProgress.hidden = isHidden;
    }
}

@end
