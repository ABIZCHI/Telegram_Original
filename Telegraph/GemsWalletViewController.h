//
//  GemsWalletViewController.h
//  GetGems
//
//  Created by alon muroch on 3/10/15.
//
//

#import <UIKit/UIKit.h>
#import "TGViewController.h"
#import "PaymentRequestsContainer.h"
#import "BalancesView.h"
#import "TxTableView.h"
#import "WalletHeaderView.h"

@interface GemsWalletViewController : TGViewController <BalancesViewDelegate>


@property (strong, nonatomic) TxTableView *tblTransactions;
@property (strong, nonatomic) WalletHeaderView *walletHeaderView;
// A colored view so when the tableview is pulled down the color remains the same
@property(nonatomic, strong) UIView *topColoredView;

-(void)refreshUi;
- (void)onNextViewAppearanceJumpToPayment:(PaymentRequestsContainer*)pr;

- (void)changeSelectedAssetTo:(NSString*)asset;

- (void)launchKeypadControllerWithPaymentRequest:(PaymentRequestsContainer*)request closeScanView:(BOOL)closeScanView;

+ (void)removeGemsCachedTx;
+ (void)removeBitcoinCachedTx;

@end
