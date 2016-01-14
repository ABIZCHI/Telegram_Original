//
//  TGScanViewController.m
//  GetGems
//
//  Created by alon muroch on 7/31/15.
//
//

#import "TGScanViewController.h"
#import "TGAppDelegate.h"
#import "GemsNavigationController.h"

@interface TGScanViewController ()

@end

@implementation TGScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(IS_IPAD)
        [((GemsNavigationController*)self.navigationController) setNavigationBarHidden:YES];
}

#pragma mark - IBActions

- (IBAction)close:(id)sender {
    [super close:sender];
    [TGAppDelegateInstance dismissViewControllerAnimated:YES];
}

- (IBAction)btnPasteAddressPressed:(id)sender {
    [super btnPasteAddressPressed:sender];
    
    BitcoinAddress *copiedAddress = [UIPasteboard generalPasteboard].string;
    if([_B validateAddress:copiedAddress])
    {
        PaymentRequestsContainer *container = [PaymentRequestsContainer Factory_newSinglePayment];
        container.ledgerType = OnChainPayment;
        PaymentRequest *pr = [[PaymentRequest alloc] init];
        pr.paymentAddress = copiedAddress;
        container.currency = GEMS.globalSelectedCurrency;
        [container.paymentRequests addObject:pr];
        [TGAppDelegateInstance dismissViewControllerAnimated:YES];
        [[TGAppDelegateInstance.rootController gemsWalletController] launchKeypadControllerWithPaymentRequest:container closeScanView:NO];
    }
    else
    {
        [UserNotifications showUserMessage:GemsLocalized(@"GemsErrorCopying")];
    }
}

@end
