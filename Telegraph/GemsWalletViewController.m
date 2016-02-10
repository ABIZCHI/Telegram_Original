//
//  GemsWalletViewController.m
//  GetGems
//
//  Created by alon muroch on 3/10/15.
//
//

#import "GemsWalletViewController.h"

#import "GemsAccountSettingsController.h"
#import "TGScanViewController.h"
#import "TGGemsRequestPaymentController.h"
#import "GemsEventObservers.h"
#import "TGAttachmentSheetButtonItemView.h"
#import "TxDetailsView.h"
#import "TxDataSource.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <QuartzCore/QuartzCore.h>
#import "TGAppDelegate.h"
#import "TGGemsWallet.h"
#import "TGImageUtils.h"
#import "TGNavigationBar.h"

// GemsUI
#import <GemsUI/UIImage+Loader.h>
#import <GemsUI/GemsUI.h>
#import <GemsUI/UserNotifications.h>
#import <GemsUI/UILabel+ShortenFormating.h>
#import <GemsUI/iToast+Gems.h>
#import <GemsUI/UserNotifications.h>
#import <GemsUI/FlippingTitleView.h>
#import <GemsUI/FXBlurView.h>
#import <GemsUI/GemsNumberPadViewController.h>

// GemsCore
#import <GemsCore/GemsCD.h>
#import <GemsCore/GemsStringUtils.h>
#import <GemsCore/NSURL+GemsReferrals.h>
#import <GemsCore/GemsAnalytics.h>

@interface GemsWalletViewController () <AVCaptureMetadataOutputObjectsDelegate, UIScrollViewDelegate, TxTableViewDelegate>
{
    PaymentRequestsContainer *_prContainerForNextViewAppearance;
    
    GemsAccountSettingsController *_settingsController;
    TGScanViewController *_scanController;
    TGGemsRequestPaymentController *_requestPaymentController;
    
    UIRefreshControl *_refreshControl;
    
    UIView *_container;
    
    FlippingTitleView *_navigationItemView;
}

@property (nonatomic, strong) UIView *activityView;

@end

@implementation GemsWalletViewController


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        if([_B isActive])
        {
            [[GemsEventObservers sharedInstance] setupWithController:self];
        }
        
        GEMS.globalSelectedCurrency = _G;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpGlobalAssetObserver];
    
    _navigationItemView = [[FlippingTitleView alloc] initWithMainTitle:GemsLocalized(@"GemMainTitleWallet") bottomTitle:@"" topTitle:@""];
    
    _container = [[UIView alloc] init];
    [self.view addSubview:_container];
    
    _topColoredView = [[UIView alloc] init];
    _topColoredView.backgroundColor = [GemsAppearance navigationBackgroundColor];
    [_container addSubview:_topColoredView];
    
    _tblTransactions = [[TxTableView alloc] init];
    _tblTransactions.scrollingDelegateProxy = self;
    _tblTransactions.txTableDelegate = self;
    [_tblTransactions setShowsVerticalScrollIndicator:NO];
    [_container addSubview:_tblTransactions];
    
    _refreshControl = [[UIRefreshControl alloc]init];
    _refreshControl.tintColor = [GemsAppearance navigationTextColor];
    [_tblTransactions addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    _walletHeaderView = [WalletHeaderView new];
    [_tblTransactions setTableHeaderView:_walletHeaderView];
    
    _scanController = [TGScanViewController new];
    _scanController.delegate = self;
    
    _requestPaymentController = [[TGGemsRequestPaymentController alloc] initWithNibName:@"GemsRequestPaymentController" bundle:GemsUIBundle];
    
    _tblTransactions.scrollingDelegateProxy = self;
}

-(void)initNavBar
{
    [self setTitleText:GemsLocalized(@"GemMainTitleWallet")];

    self.navigationController.navigationBar.clipsToBounds = YES;
    [self setTitleView:_navigationItemView];
    if(Currencies.exchangeDataLoadingFinished)
        [self updateExchangeLabel];
    
    // left icons
    {
        UIButton *btnSend = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 20)];
        [btnSend addTarget:self action:@selector(requestPaymentPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btnSend setBackgroundImage:[UIImage Loader_gemsImageWithName:@"receive"] forState:UIControlStateNormal];
        UIBarButtonItem *r1 = [[UIBarButtonItem alloc] initWithCustomView:btnSend];
        [self setLeftBarButtonItems:@[r1] animated:NO];
    }
    
    // right icons
    {
        UIButton *btnQR = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 20)];
        [btnQR addTarget:self action:@selector(sendPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btnQR setBackgroundImage:[UIImage Loader_gemsImageWithName:@"send"] forState:UIControlStateNormal];
        UIBarButtonItem *r1 = [[UIBarButtonItem alloc] initWithCustomView:btnQR];
        [self setRightBarButtonItems:@[r1] animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initNavBar];
    
    
    if(_prContainerForNextViewAppearance) {
        GemsNumberPadViewController *v = [[GemsNumberPadViewController alloc] initWithNibName:@"GemsNumberPadViewController" bundle:GemsUIBundle];
        v.closePressed = ^{
//            TGAppDelegateInstance.tabletMainViewController.detailViewController = nil;
        };
        v.initialCurrency = _prContainerForNextViewAppearance.currency;
        v.prContainer = _prContainerForNextViewAppearance;
        
        pushController(v, YES);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initNavBar];
    [self refreshUi];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setRightBarButtonItems:@[] animated:NO];
    [self setLeftBarButtonItems:@[] animated:NO];
    
    // so the next time it wont open it again
    _prContainerForNextViewAppearance = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //
    self.navigationController.navigationBar.clipsToBounds      = NO;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _container.frame = self.view.frame;
    
    _topColoredView.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
    
    CGFloat h = self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height - 15;
    _tblTransactions.frame = CGRectMake(0, 60, self.view.frame.size.width, h);
    {
        CGRect r = CGRectMake(0, 0, self.view.frame.size.width, WalletHeaderViewHeight);
        _walletHeaderView.frame = r;
    }
    [_tblTransactions setTableHeaderView:_walletHeaderView];
}

-(void)refreshUi
{
    [self loadBalance];
    [_tblTransactions reloadDataFromServerWithCompletion:^(NSError __unused *errorc) {
        [_refreshControl endRefreshing];
    }];
}

- (void)refreshTable {
    [self refreshUi];
}

- (void)onNextViewAppearanceJumpToPayment:(PaymentRequestsContainer*)pr
{
    _prContainerForNextViewAppearance = pr;
}

-(void)loadBalance {
    NSLog(@"Refreshing gems wallet balances from network");
    [_G updateBalance:^(DigitalTokenAmount newBalance) {
        NSNumber *gemsBalance = [@(newBalance) currency_gillosToGems];
        NSNumber *btcBalance = [@([_B balance]) CD_satoshiToSysUnit];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_walletHeaderView updateBalanceToNewGemsBalance:gemsBalance newBtc:btcBalance];
            [self updateFlippingNavTitleItemBalance:gemsBalance newBtc:btcBalance];
        });
    }];
    
    [_B updateBalance:^(DigitalTokenAmount newBalance) {
        NSNumber *gemsBalance = [@([_G balance]) currency_gillosToGems];
        NSNumber *btcBalance = [@(newBalance) CD_satoshiToSysUnit];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_walletHeaderView updateBalanceToNewGemsBalance:gemsBalance newBtc:btcBalance];
            [self updateFlippingNavTitleItemBalance:gemsBalance newBtc:btcBalance];
        });
    }];
}

- (void)updateFlippingNavTitleItemBalance:(NSNumber*)newGems newBtc:(NSNumber*)newBtc
{
    if(GEMS.globalSelectedCurrency == _G)
        _navigationItemView.bottomLbl.text = [NSString stringWithFormat:@"%@ GEMS", formatDoubleToStringWithDecimalPrecision([newGems doubleValue], 3)];
    else
        _navigationItemView.bottomLbl.text = [NSString stringWithFormat:@"%@ %@", formatDoubleToStringWithDecimalPrecision([newBtc doubleValue], sysDecimalPrecisionForUI(_B)), [GemsStringUtils btcSysUnitName]];
}

#pragma mark - currency coversion
-(NSString*)getFiatCode
{
    CDGemsSystem *s = [CDGemsSystem MR_findFirst];
    return [s.currencySymbol uppercaseString];
}

#pragma mark - IBOutlet

- (IBAction)requestPaymentPressed:(id)sender {
    [self launchReqPaymentController:YES];
}

- (IBAction)sendPressed:(id)sender {
    presentController(_scanController, YES);
}

- (IBAction)settingsPressed:(id)sender {
    pushController(_settingsController, YES);
}

- (void)launchReqPaymentController:(BOOL)animated
{
    _requestPaymentController.initialCurrency = GEMS.globalSelectedCurrency;
    if(GEMS.globalSelectedCurrency == _G)
    {
        if (![_G depositAddress]) {
            [self showActivityIndicator];
            // We call get deposit address here so that we could save the number of generated addresses
            // in the server. The address will be generated only when the user actually wants to use it.
            [Currencies.api getGemsDepositAddress:^(GemsNetworkRespond *respond) {
                [self hideActivityIndicator];
                if(![respond hasError])
                {
                    [_G setDepositAddress:respond.rawResponse[@"address"]];
                    _requestPaymentController.address = [_G depositAddress];
                    presentController(_requestPaymentController, YES);
                }
                else {
                    [UserNotifications showUserMessage:[respond error].localizedError];
                }
            }];
        }
        else {
            _requestPaymentController.address = [_G depositAddress];
            presentController(_requestPaymentController, YES);
        }
    }
    else
    {
        _requestPaymentController.address = [_B depositAddress];
        presentController(_requestPaymentController, YES);
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
bool readyForQR = true;
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    if(!readyForQR) return;

    for (AVMetadataMachineReadableCodeObject *o in metadataObjects) {
        if (! [o.type isEqual:AVMetadataObjectTypeQRCode]) continue;
        
        NSString *s = o.stringValue;
        
        PaymentRequestsContainer *prContainer = [PaymentRequestsContainer newWithString:s];
        
        if([prContainer isValid])
        {
            NSLog(@"Scanned a valid QR code: %@", s);
            
            [self trackQRScanned:prContainer rawData:s];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                _scanController.cameraView.cameraGuide.image = [UIImage Loader_gemsImageWithName:@"CameraGuide-green"];
            }];
            
            [self launchKeypadControllerWithPaymentRequest:prContainer closeScanView:IS_IPAD ? NO:YES];
        }
        else
        {
            NSLog(@"Scanned a invalid QR code: %@", s);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                _scanController.cameraView.cameraGuide.image = [UIImage Loader_gemsImageWithName:@"CameraGuide-red"];
            }];
            
            readyForQR = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 350 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                [self resetQRGuide];
                readyForQR = YES;
            });
        }

    }
}


#pragma mark - scan controller helpers

- (void)resetQRGuide
{
    _scanController.cameraView.cameraGuide.image = [UIImage Loader_gemsImageWithName:@"CameraGuide-normal"];
}

-(void)closeScanView
{
    [_scanController close:nil];
}

- (void)launchKeypadControllerWithPaymentRequest:(PaymentRequestsContainer*)container closeScanView:(BOOL)closeScanView
{
    if(![container isValid]) return;
    
    [_scanController stop];
    [self performSelector:@selector(resetQRGuide) withObject:nil afterDelay:0.35];
    if(closeScanView)
        [self performSelector:@selector(closeScanView) withObject:nil afterDelay:0.70];
    
    // load send view
    GemsNumberPadViewController *v = [[GemsNumberPadViewController alloc] initWithNibName:@"GemsNumberPadViewController" bundle:GemsUIBundle];
    v.closePressed = ^{
//        TGAppDelegateInstance.tabletMainViewController.detailViewController = nil;
    };
    [v setPrContainer:container];
    v.initialCurrency = container.currency;
    pushController(v, YES);
}


#pragma mark - screen orientation

- (NSUInteger) supportedInterfaceOrientations
{
    if(TGIsPad())
        return UIInterfaceOrientationMaskAll;
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = [self calculateTableViewRealContentOffset:scrollView];
    [_walletHeaderView animateForScrollViewOffset:offset];
    
    [self animateNavTitleViewForOffset:offset];
}

- (void)animateNavTitleViewForOffset:(CGFloat)offset
{
    if(offset < 0)
    {
        CGFloat startingOffset = -_walletHeaderView.frame.size.height + 70;
        CGFloat endOffset = -_walletHeaderView.frame.size.height;
        if(offset < endOffset)
            offset = endOffset;
        if(offset > startingOffset)
            offset = startingOffset;
        CGFloat per = fabs((offset - startingOffset) / (endOffset - startingOffset)) * -1; // make sure its negative
        [_navigationItemView transitionBetweenMasterLabelAndSlaveLabelForPercentage:per];
    }
    else
    {
        CGFloat startingOffset = 10;
        CGFloat endOffset = 50;
        if(offset > endOffset)
            offset = endOffset;
        if(offset < startingOffset)
            offset = startingOffset;
        CGFloat per = (offset - startingOffset) / (endOffset - startingOffset);
        [_navigationItemView transitionBetweenMasterLabelAndSlaveLabelForPercentage:per];
    }
}

- (CGFloat)calculateTableViewRealContentOffset:(UIScrollView*)scrl
{
    static CGFloat initialScrlOffset;
    if(!initialScrlOffset)
        initialScrlOffset = scrl.contentOffset.y;
    return -(scrl.contentOffset.y - initialScrlOffset);;
}

//- (CGFloat)calculateParallaxHeaderViewYOffsetForOffset:(CGFloat)offset
//{
//    return 44 + offset;
//}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{

}

#pragma mark - analytics
//- (void)trackAddressCopied:(NSString*)address
//{
//    trackAnalyticsEvent(AnalyticsAddressCopied, @{@"address": address});
//}

- (void)trackQRScanned:(PaymentRequestsContainer*)pr rawData:(NSString*)data
{
    [GemsAnalytics track:AnalyticsQRScanned args:@{@"asset_type": [pr.currency symbol], @"data": data}];
}

#pragma mark - pub method

- (void)changeSelectedCurrencyTo:(Currency*)currency
{
    [_walletHeaderView.balancesView scrollToCurrency:currency animated:YES];
}

#pragma mark -
- (void)setUpGlobalAssetObserver
{
    [GEMS addObserver:self forKeyPath:@"globalSelectedCurrency" options:NSKeyValueObservingOptionNew context:nil];
    
    [_B addObserver:self forKeyPath:@"isActive" options:NSKeyValueObservingOptionNew context:nil];
    [_G addObserver:self forKeyPath:@"isActive" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateExchangeRates:) name:DidUpdatedExchangeRates object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"globalSelectedCurrency"]) {
        [self updateExchangeLabel];
        
        NSNumber *gemsBalance = [@([_G balance]) currency_gillosToGems];
        NSNumber *btcBalance = [@([_B balance]) CD_satoshiToSysUnit];
        [self updateFlippingNavTitleItemBalance:gemsBalance newBtc:btcBalance];
    }
    
    if([keyPath isEqual:@"isActive"]) // for all currencies
    {
        [_walletHeaderView setBalancesView];
    }
}

- (void) didUpdateExchangeRates:(NSNotification *) notification
{
    [self updateExchangeLabel];
    [self loadBalance];
}

- (void)updateExchangeLabel
{
    NSString *fiatStr  = [GemsStringUtils systemFiatCode], *value;
    if(GEMS.globalSelectedCurrency == _G)
    {
        NSNumber *n = [NSNumber oneGemToSysCurrency];
        value = formatDoubleToStringWithDecimalPrecision([n doubleValue], 3);
    }
    else
    {
        NSNumber *n = [NSNumber oneBtcToSysCurrency];
        value = formatDoubleToStringWithDecimalPrecision([n doubleValue], 3);
    }
    
    _navigationItemView.topLbl.text = [NSString stringWithFormat:@"1 %@ | %@ %@", [GEMS.globalSelectedCurrency symbol], value, fiatStr];
}

#pragma mark - TxTableViewDelegate

- (void)txTableView:(TxTableView*)tableView didSelectTransaction:(Transaction*)transaction
{
    UIView *keyView = [UIApplication sharedApplication].keyWindow;
    
    // dark bg
    UIView *shadow = [[UIView alloc] initWithFrame:keyView.frame];
    shadow.backgroundColor = [UIColor blackColor];
    shadow.alpha = 0.15f;
    [keyView addSubview:shadow];

    FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:keyView.frame];
    blurView.dynamic = NO;
    blurView.blurRadius = 20.0f;
    blurView.tintColor = [UIColor blackColor];
    [keyView addSubview:blurView];
    
    TxDetailsView *detailsView = [TxDetailsView newWithTransaction:transaction];
    detailsView.frame = CGRectMake(0, 0, 300, transaction.type == TxPurchase? TxDetailsViewExtendedHeight:TxDetailsViewNormalHeight);
    detailsView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    detailsView.center = keyView.center;
    detailsView.showDetailsView = transaction.type == TxPurchase;
    detailsView.close = ^ {
        [shadow removeFromSuperview];
        [detailsView removeFromSuperview];
        [blurView removeFromSuperview];
    };
    blurView.backgroundTapped = ^ {
        [shadow removeFromSuperview];
        [detailsView removeFromSuperview];
        [blurView removeFromSuperview];
    };
    [keyView addSubview:detailsView];
        
    // animate to full size
    [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            detailsView.transform = CGAffineTransformIdentity;
                        } completion:nil];
}

#pragma mark -
+ (void)logoutCleanup
{
    NSLog(@"Cleaned up wallet NSDefaults");
    [TxDataSource removeAllCachedTxs];
}

+ (void)removeGemsCachedTx
{
    [TxDataSource removeGemsCachedTx];
}

+ (void)removeBitcoinCachedTx
{
    [TxDataSource removeBitcoinCachedTx];
}

#pragma mark - activity indicator
- (void)showActivityIndicator {
    UIWindow *w = [UIApplication sharedApplication].keyWindow;
    if (!self.activityView) {
        self.activityView = [[UIView alloc] initWithFrame:w.frame];
        
        //bg
        UIView *bg = [[UIView alloc] initWithFrame:w.frame];
        bg.backgroundColor = [UIColor blackColor];
        bg.alpha = 0.5f;
        [self.activityView addSubview:bg];
        
        // spinnner
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.center = w.center;
        [spinner startAnimating];
        [self.activityView addSubview:spinner];
    }
    
    [w addSubview:self.activityView];
}

- (void)hideActivityIndicator {
    if (self.activityView) {
        [self.activityView removeFromSuperview];
        self.activityView = nil;
    }
}

@end
