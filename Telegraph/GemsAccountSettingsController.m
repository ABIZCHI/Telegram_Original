//
//  GemsAccountSettingsController.m
//  GetGems
//
//  Created by alon muroch on 3/12/15.
//
//

#import "GemsAccountSettingsController.h"
#import "TGCollectionMenuSection.h"
#import "TGDisclosureActionCollectionItem.h"
#import "TGCommentCollectionItem.h"
#import "TGGemsWallet.h"
#import "CoachMarks.h"
#import "TGImageUtils.h"
#import "GemsNavigationController.h"
#import "TGAppDelegate.h"
#import "TGVariantCollectionItem.h"
#import "ReferralLinkItem.h"
#import "GemsCurrencySelectionController.h"
#import "BitcoinUnitSelectionController.h"
#import "TGSwitchCollectionItem.h"
#import "GemsWalletViewController.h"
#import "PincodeManagerController.h"
#import "TGGemsFaqController.h"
#import "TGTelegraph.h"
#import "TGGems.h"
#import "GemsEventObservers.h"
#import "GemsAccountSettingsSPVHelper.h"
#import <MessageUI/MessageUI.h>

// GemsUI
#import <GemsUI/GemsUI.h>
#import <GemsUI/GemsPinCodeView.h>
#import <GemsUI/BtcOnboardingMenu.h>
#import <GemsUI/BtcRecoverWalletController.h>
#import <GemsUI/UIImage+Loader.h>
#import <GemsUI/iToast+Gems.h>
#import <GemsUI/DiamondActivityIndicator.h>
#import <GemsUI/UserNotifications.h>

// GemsCore
#import <GemsCore/GemsCD.h>
#import <GemsCore/GemsLocalization.h>
#import <GemsCore/GemsCommons.h>
#import <GemsCore/GemsStringUtils.h>
#import <GemsCore/NSURL+GemsReferrals.h>


@interface GemsAccountSettingsController ()
{
    NSString *_referralLinkStr;
    ReferralLinkItem *_referralLinkCell;
    
    TGVariantCollectionItem *_currencySelection, *_bitcoinUnitSelection;
}

@end

@implementation GemsAccountSettingsController

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
    
    CDGemsSystem *sys = [CDGemsSystem MR_findFirst];
    [_currencySelection setVariant:[sys.currencySymbol uppercaseString]];
    [_bitcoinUnitSelection setVariant:[GemsStringUtils bitcoinSymbolForDenomination:[sys.bitcoinDenomination intValue]]];
}

- (id)initWithUid:(int32_t)uid
{
    self = [super initWithUid:uid];
    if(self !=nil)
    {
        [super setSections];
        [self setSections];
    }
    return self;
}

- (void)clearAllSections
{
    // remove only gems settings menu
    if(self.menuSections.sections) {
        [self.menuSections deleteSection:(self.menuSections.sections.count - 1)];
        [self.menuSections deleteSection:(self.menuSections.sections.count - 1)];
        [self.menuSections deleteSection:(self.menuSections.sections.count - 1)];
    }
}

- (void)setSections
{
    // set only gems settings menu
    [NSURL urlWithMyUniqueReferralLinkCompletion:^(NSURL *url, NSError *error) {
        if(!error) {
            _referralLinkStr = url.absoluteString;
            
            // added gems user name
            CDGemsUser *user = [CDGemsUser MR_findFirst];
            CDGemsSystem *sys = [CDGemsSystem MR_findFirst];
            
            _referralLinkCell = [[ReferralLinkItem alloc] initWithReferralLink:_referralLinkStr icont:[UIImage Loader_gemsImageWithName:@"settings_copy_referral"] action:@selector(copyReferralLinkPressed)];
            [_referralLinkCell setDeselectAutomatically:YES];
            
            TGVariantCollectionItem *referralCnt = [[TGVariantCollectionItem alloc] initWithTitle:GemsLocalized(@"GemsReferrals") icon:[UIImage Loader_gemsImageWithName:@"settings_referrals_cnt"] action:nil];
            [referralCnt setVariant:[NSString stringWithFormat:@"%d", (int)[TGGemsWallet sharedInstance].cntReferrals]];
            [referralCnt setSelectable:NO];
            
            TGVariantCollectionItem *gemsEarned = [[TGVariantCollectionItem alloc] initWithTitle:GemsLocalized(@"GemsEarned") icon:[UIImage Loader_gemsImageWithName:@"settings_gems_earned"] action:nil];
            [gemsEarned setVariant:[NSString stringWithFormat:@"%d", (int)[TGGemsWallet sharedInstance].gemsEarned]];
            [gemsEarned setSelectable:NO];
            
            _currencySelection = [[TGVariantCollectionItem alloc] initWithTitle:GemsLocalized(@"GemsNativeCurrency") icon:[UIImage Loader_gemsImageWithName:@"settings_default_currency"] action:@selector(currencySelectionPressed)];
            [_currencySelection setVariant:[sys.currencySymbol uppercaseString]];
            [_currencySelection setDeselectAutomatically:YES];
            
            //                TGDisclosureActionCollectionItem *showCoachMark = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Gems.settings.resetCoachMarks") icon:[UIImage imageNamed:@"settings_replay"] action:@selector(showCoachMarksPressed)];
            //                [showCoachMark setDeselectAutomatically:YES];
            
            BOOL didSetPincode = user.pinCodeHash? YES: NO;
            TGDisclosureActionCollectionItem *pincode = [[TGDisclosureActionCollectionItem alloc] initWithTitle:GemsLocalized(@"Pincode") icon:[UIImage Loader_gemsImageWithName:@"settings_security"] action:@selector(setOrChangePincode)];
            [pincode setDeselectAutomatically:YES];
            
            TGCollectionMenuSection  *newSection = [[TGCollectionMenuSection alloc] initWithItems:@[_referralLinkCell, referralCnt, gemsEarned, _currencySelection, pincode /*resetPinCode, showCoachMark*/]];
            [self.menuSections addSection:newSection];
            
            /////////////// Bitcoin ////////////////////////
            if([_B isActive])
            {
                // bitcoin unit
                _bitcoinUnitSelection = [[TGVariantCollectionItem alloc] initWithTitle:GemsLocalized(@"GemsBitcoinDisplayUnit") icon:[UIImage Loader_gemsImageWithName:@"settings_bitcoin_unit"] action:@selector(bitcoinUnitSelectionPressed)];
                [_bitcoinUnitSelection setVariant:[GemsStringUtils bitcoinSymbolForDenomination:[sys.bitcoinDenomination intValue]]];
                [_bitcoinUnitSelection setDeselectAutomatically:YES];
                
                // passphrase recovery
                TGDisclosureActionCollectionItem *passphraseRecovery = [[TGDisclosureActionCollectionItem alloc] initWithTitle:GemsLocalized(@"RecoveryPassphrase") icon:[UIImage Loader_gemsImageWithName:@"settings_passphrase"] action:@selector(passphraseRecoveryPressed)];
                [passphraseRecovery setDeselectAutomatically:YES];
                
                TGCollectionMenuSection  *newSection = [[TGCollectionMenuSection alloc] initWithItems:@[passphraseRecovery, _bitcoinUnitSelection]];
                [self.menuSections addSection:newSection];
            }
            else {
                TGVariantCollectionItem *setupBitcoinWallet = [[TGVariantCollectionItem alloc] initWithTitle:GemsLocalized(@"SetupBitcoinWallet") icon:[UIImage Loader_gemsImageWithName:@"settings_bitcoin_unit"] action:@selector(setupBitcoinSelected)];
                [setupBitcoinWallet setDeselectAutomatically:YES];
                
                TGCollectionMenuSection  *newSection = [[TGCollectionMenuSection alloc] initWithItems:@[setupBitcoinWallet]];
                [self.menuSections addSection:newSection];
            }
            
            ////////////////////////////////////////////////
            
            
            /////////////// Coinbase ////////////////////////
            
            //                TGDisclosureActionCollectionItem *coinbase = [[TGDisclosureActionCollectionItem alloc] initWithTitle:TGLocalized(@"Gems.settings.Coinbase") icon:[UIImage imageNamed:@"coinbase_icon"] action:@selector(coinbaseSelected)];
            //                [bitcoinUnitSelection setDeselectAutomatically:YES];
            //
            //                TGCollectionMenuSection  *newSection2 = [[TGCollectionMenuSection alloc] initWithItems:@[coinbase]];
            //                [self.menuSections addSection:newSection2];
            
            ////////////////////////////////////////////////
            
            TGDisclosureActionCollectionItem *faq = [[TGDisclosureActionCollectionItem alloc] initWithTitle:GemsLocalized(@"Settings.FAQ_Button") icon:[UIImage Loader_gemsImageWithName:@"settings_faq"] action:@selector(faqPressed)];
            [faq setDeselectAutomatically:YES];
            
            TGDisclosureActionCollectionItem *contactUs = [[TGDisclosureActionCollectionItem alloc] initWithTitle:GemsLocalized(@"GemsContactUs") icon:[UIImage Loader_gemsImageWithName:@"settings_contat"] action:@selector(contactUsPressed)];
            [contactUs setDeselectAutomatically:YES];
            
            NSString *appVerison = ValueFromAppPlist(@"CFBundleShortVersionString");
            TGCommentCollectionItem *version = [[TGCommentCollectionItem alloc] initWithText:[NSString stringWithFormat:@"GetGems Version %@", appVerison]];
            
            TGCollectionMenuSection  *newSection3 = [[TGCollectionMenuSection alloc] initWithItems:@[faq, contactUs, version]];
            [self.menuSections addSection:newSection3];
            
            [self.collectionView reloadData];
        }
    }];
}

//- (void)resetPinCodePressed
//{
//    /*
//     *
//     * Verifiy currentPinCode
//     *
//     */
//}

- (void)setOrChangePincode
{
    CDGemsUser *user = [CDGemsUser MR_findFirst];
    if(user.pinCodeHash) {
        GemsPinCodeView *pincode = [GemsPinCodeView new];
        [pincode authenticatePin:user.pinCodeHash
                       WithTitle:@""
                         message:GemsLocalized(@"ConfirmWalletPinCode")
                      completion:^(BOOL isVerified, NSDictionary *data, NSString *errorString) {
                          if(isVerified)
                          {
                              PincodeManagerController *v = [PincodeManagerController new];
                              [TGAppDelegateInstance pushViewController:v animated:YES];
                          }
                      }];
    }
    else {
        PincodeManagerController *v = [PincodeManagerController new];
        [TGAppDelegateInstance pushViewController:v animated:YES];
    }
}

- (void)setupBitcoinSelected
{
    // download user data
    [self showIndicator];
    NSArray *param = @[@{@"telegramUserId" : [@(TGTelegraphInstance.clientUserId) stringValue]
                           }];
    [API getGemsUserInfoByTelegramIds:param respond:^(GemsNetworkRespond *respond) {
        [self hideIndicator];

        if([respond hasError]) {
            [UserNotifications showUserMessage:respond.error.localizedError];
            return ;
        }
        
        NSArray *results = (NSArray*)respond.rawResponse[@"records"];
        if(results.count == 0) {
            [UserNotifications showUserMessage:@"Cannot get user details"];
            return ;
        }
        
        NSString *btcAddressAlias = ((NSDictionary*)results[0])[@"btcAddress"];
        if(btcAddressAlias.length == 0) btcAddressAlias = nil;
        BOOL userDidSetBtcWallet = btcAddressAlias.length > 0;
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"GemsOnBoarding" bundle:GemsUIBundle];
        BtcOnboardingMenu *v = (BtcOnboardingMenu *)[sb instantiateViewControllerWithIdentifier:@"BtcOnboardingMenu"];
        v.userDidSetBtcWallet = userDidSetBtcWallet;
        v.selectedPassphrase = ^(NSString *passphrase, BOOL isNew) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // refresh settings menu
                [self clearAllSections];
                [self setSections];
            }];
            
            // check passphrase is the same as know in the server
            if(btcAddressAlias) {
                if(![[self passphraseReceiveAddress:passphrase] isEqualToString:btcAddressAlias])
                {
                    [UserNotifications showUserMessage:GemsLocalized(@"GemsClientVerificationUserWrongPassphrase")];
                    return;
                }
            }
            
            // make sure a pincode was set
            [self setPincode:^(BOOL didSet) {
                if(didSet) {
                    // activate bitcoin wallet
                    [self activateBitcoinWalletAndPopWithPassphrase:passphrase isNewPassphrase:isNew];
                }
            }];
        };
        [TGAppDelegateInstance pushViewController:v animated:YES];
        
        if(IS_IPAD)
            [v setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closeBitcoinOnboardingController)]];
    }];
}

- (void)closeBitcoinOnboardingController
{
    [TGAppDelegateInstance dismissViewControllerAnimated:YES];
}

- (void)activateBitcoinWalletAndPopWithPassphrase:(NSString*)passphrase isNewPassphrase:(BOOL)isNew
{
    NSLog(@"activating bitcoin wallet");
    [Currencies setCurrency:CurrencyTypeBitcoin active:YES reload:NO];
    [_B setPassphrase:passphrase];
    if(isNew)
        [_B setPassphraseCreationTime:[NSDate timeIntervalSinceReferenceDate]];
    [_B load];
    
    [[GemsEventObservers sharedInstance] setupWithController:TGAppDelegateInstance.rootController.gemsWalletController];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // refresh settings menu
        [self clearAllSections];
        [self setSections];        
    }];
    
    
    // solves some weird eace situations that blocks [BRWalletManager wallet]
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [API setBitcoinWalletAddress:[_B depositAddress] respond:^(GemsNetworkRespond *respond) {
            if([respond hasError])
            {
                [UserNotifications showUserMessage:respond.error.localizedError];
            }
        }];
    });
    
    if(IS_IPAD) {
        [TGAppDelegateInstance dismissViewControllerAnimated:YES];
    }
    else {
        // dismiss btc wallet controllers
//        PopUntil(self, [GemsMainTabsController class], Animated);
    }
}

- (NSString*)passphraseReceiveAddress:(NSString*)passphrase
{
    return [GemsAccountSettingsSPVHelper receiveAddressFromPassphrase:passphrase];
}

- (void)setPincode:(void(^)(BOOL didSet))completion
{
    CDGemsUser *user = [CDGemsUser MR_findFirst];
    if(user.pinCodeHash) {
        if(completion)
            completion(AUTHENTICATED);
        return;
    }
    
    GemsPinCodeView *v = [GemsPinCodeView new];
    [v setPinWithCompletion:^(BOOL result, NSDictionary *data, NSString *errorString) {
        if(result) {
            // set pincode hash
            NSString *pincodehash = data[@"pinHash"];
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                CDGemsUser *user = [CDGemsUser MR_findFirstInContext:localContext];
                user.pinCodeHash = pincodehash;
            } completion:^(BOOL contextDidSave, NSError *error) {
                if(completion)
                    completion(AUTHENTICATED);
            }];
        }
    }];
}

- (void)contactUsPressed
{
    CDGemsUser *user = [CDGemsUser MR_findFirst];
    TGUser *tgUser = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
    NSString *appVerison = ValueFromAppPlist(@"CFBundleShortVersionString");
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSString *buildVersion = ValueFromAppPlist(@"CFBundleVersion");
    NSString *clientDetails = [NSString stringWithFormat:@"Username: %@, First name: %@, GemsId : %@, Locale: %@, Device iOS, iOS version %@,  app version %@, app build version: %@",
                               user.userName,
                               tgUser.firstName,
                               user.gemsUserId,
                               locale,
                               osVersion,
                               appVerison,
                               buildVersion];
    
    
    // Email Subject
    NSString *emailTitle = @"My 2 cents about GetGems";
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"Hi GetGems team! \n\n\n\n\n\n\n\n\nMy Details (%@)", clientDetails];
    // To address
    NSArray *toRecipents = @[GEMS_SUPPORT_URL];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    [self presentViewController:mc animated:YES completion:NilCompletionBlock];
}

- (void)faqPressed
{
    TGGemsFaqController *v = [[TGGemsFaqController alloc] initWithNibName:@"FAQViewController" bundle:GemsUIBundle];
    [TGAppDelegateInstance pushViewController:v animated:YES];
}

-(void)myUserNamePressed
{
    
}

- (void)copyReferralLinkPressed
{
    static BOOL didFinishAnimating = YES;
    
    if(!didFinishAnimating) return;
    [[UIPasteboard generalPasteboard] setString:_referralLinkStr];

    UIView *v = [[UIView alloc] init];
    v.frame = CGRectMake(30, 0, _referralLinkCell.view.frame.size.width, _referralLinkCell.view.frame.size.height);
    v.backgroundColor = [UIColor whiteColor];
    UILabel *lbl = [[UILabel alloc] init];
    lbl.frame = v.frame;
    lbl.font = _referralLinkCell.view.lblLink.font;
    lbl.textColor = _referralLinkCell.view.lblLink.textColor;
    lbl.text = [NSString stringWithFormat:@"%@:\n%@", GemsLocalized(@"ReferralUrlCopied"), _referralLinkStr];
    lbl.numberOfLines = 0;
    [v addSubview:lbl];
    
    didFinishAnimating = NO;
    [UIView transitionWithView:_referralLinkCell.view duration:0.7f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_referralLinkCell.view addSubview:v];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView transitionWithView:_referralLinkCell.view duration:0.5f options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
                [v removeFromSuperview];
            } completion:^(BOOL finished) {
                didFinishAnimating = YES;
            }];
        });
    }];
}

- (void)currencySelectionPressed
{
    GemsCurrencySelectionController *v = [[GemsCurrencySelectionController alloc] init];
    v.completionBlock = ^{
        if(TGIsPad()) {
//            TGAppDelegateInstance.tabletMainViewController.detailViewController = nil;
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    if(TGIsPad()) {
        GemsNavigationController *navigationController = [GemsNavigationController navigationControllerWithControllers:@[v]];
//        TGAppDelegateInstance.tabletMainViewController.detailViewController = navigationController;
    }
    else {
        [self.navigationController pushViewController:v animated:YES];
    }
}

- (void)bitcoinUnitSelectionPressed
{
    BitcoinUnitSelectionController *v = [[BitcoinUnitSelectionController alloc] init];
    v.completionBlock = ^{
        if(TGIsPad()) {
//            TGAppDelegateInstance.tabletMainViewController.detailViewController = nil;
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    if(TGIsPad()) {
        GemsNavigationController *navigationController = [GemsNavigationController navigationControllerWithControllers:@[v]];
//        TGAppDelegateInstance.tabletMainViewController.detailViewController = navigationController;
    }
    else {
        [self.navigationController pushViewController:v animated:YES];
    }
}

-(void)passphraseRecoveryPressed
{
    [GEMS showPassphraseRecoveryView];
}

- (void)logoutPressed
{
    if(![_B isActive])
    {
        [super logoutPressed];
        return;
    }
    
    BtcRecoverWalletController *v = [BtcRecoverWalletController newForMode:BtcRecoveryControllerLogout];
    v.selectedPassphrase = ^(NSString *passphrase, BOOL __unused isNew) {
        passphrase = [_B normalizePassphrase:passphrase];
        if([[_B passphrase] isEqualToString:passphrase]) {
            [_B setPassphrase:nil];
            
            [super logoutPressed];
        }
        else {
            [UserNotifications showUserMessage:GemsLocalized(@"GemsClientVerificationUserWrongPassphrase")];
        }
    };
    [TGAppDelegateInstance pushViewController:v animated:YES];
}

- (void)showCoachMarksPressed
{
    [CoachMarks resetAllCoachMarks];
    [UserNotifications showUserMessage:GemsLocalized(@"Gems.settings.weveResetTheTutorial")];
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

#pragma mark - ASWatch
//- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
//{
//    [super actionStageActionRequested:action options:options];
//    
//    if ([action isEqualToString:@"switchItemChanged"])
//    {
//        if (options[@"item"] == _enableBitcoin)
//        {
//            NSArray *action = @[^{
//                                    [_enableBitcoin setIsOn:YES];
//                                }, // cancel action
//                                 ^{
//                                     GemsPinCodeView *pincodeView = [GemsPinCodeView new];
//                                     CDGemsUser *user = [CDGemsUser MR_findFirst];
//                                     [pincodeView authenticatePin:user.pinCodeHash
//                                                        WithTitle:@""
//                                                          message:GemsLocalized(@"ConfirmWalletPinCode")
//                                                       completion:^(BOOL isVerified, NSDictionary __unused *data, NSString __unused *errorString) {
//                                                           if(isVerified)
//                                                           {
//                                                               [_B wipeWallet];
//                                                               [Currencies setCurrency:CurrencyTypeBitcoin active:NO reload:NO];
//                                                               
//                                                               [GEMS storeUserDataInKeychain:[CDGemsUser MR_findFirst]];
//                                                               
//                                                               [GemsWalletViewController removeBitcoinCachedTx]; // remove cached transactions
//
//                                                               [API setBitcoinWalletAddress:nil respond:^(GemsNetworkRespond *respond) {
//                                                                   if([respond hasError])
//                                                                   {
//                                                                       [UserNotifications showUserMessage:respond.error.localizedError];
//                                                                   }
//                                                               }];
//                                                               
//                                                               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                                                                   // refresh settings menu
//                                                                   [self clearAllSections];
//                                                                   [self setSections];
//                                                               }];
//                                                           }
//                                                           else {
//                                                               [_enableBitcoin setIsOn:YES animated:YES];
//                                                           }
//                                                       }];
//                                 }]; // ok action
//            [UserNotifications showUserMessage:GemsLocalized(@"DisableBitcoinMessage") withButtons:@[@"Cancel", @"OK"] actions:action];
//        }
//    }
//}

- (void)disableBitcoinWallet
{
    [_B wipeWallet];
    [Currencies setCurrency:CurrencyTypeBitcoin active:NO reload:NO];
        
    [GemsWalletViewController removeBitcoinCachedTx]; // remove cached transactions

}

#pragma mark - activity indicator

-(void)showIndicator
{
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    [DiamondActivityIndicator showDiamondIndicatorInView:mainWindow];
}

-(void)hideIndicator
{
    UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
    [DiamondActivityIndicator hideDiamondIndicatorFromView:mainWindow];
    
}

@end
