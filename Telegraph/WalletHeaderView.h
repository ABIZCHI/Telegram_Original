//
//  WalletTableHeaderView.h
//  GetGems
//
//  Created by alon muroch on 6/8/15.
//
//

#import "BalancesView.h"

static CGFloat WalletHeaderViewHeight = 155.0f;

@interface WalletHeaderView : UIView < BalancesViewDelegate>

+ (instancetype)new;

- (void)updateBalanceToNewGemsBalance:(NSNumber*)newGems newBtc:(NSNumber*)newBtc;

@property (strong, nonatomic) IBOutlet UIView *topContainerView;
@property (strong, nonatomic) IBOutlet UIView *bottomContainerView;

@property (strong, nonatomic) IBOutlet UILabel *lblProgress;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (strong, nonatomic) IBOutlet BalancesView *balancesView;

@property (strong, nonatomic) IBOutlet UIView *outerContainer;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *outerContainerTopConstraint;

- (void)animateForScrollViewOffset:(CGFloat)offset;
- (void)setBalancesView;

@end
