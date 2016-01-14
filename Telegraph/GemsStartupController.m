//
//  GemsLoginController.m
//  GetGems
//
//  Created by alon muroch on 3/30/15.
//
//

#import "TGGemsIntroController.h"
#import "GemsStartupController.h"

#import "GemsLoginPhoneController.h"
#import "GemsLoginCodeController.h"
#import "GemsUsenameController.h"
#import "GemsNavigationController.h"
#import "UserNotifications.h"
#import "DiamondActivityIndicator.h"
#import "CryptoUtils.h"
#import "NSURL+GemsReferrals.h"
#import "CoachMarks.h"
#import "UIDevice+PlatformInfo.h"

#import "TelegramSignupHelper.h"



#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGGemsWallet.h"

#import <GemsUI.h>
#import <Branch.h>
#import <NSString+Bitcoin.h>

// bots
#import "BotAuthenticator.h"

// Networking
#import <GemsNetworker.h>

// GemsCore
#import <GemsCD.h>
#import <GemsAnalytics.h>
#import <GemsStringUtils.h>
#import <KeyChain.h>

// Currencies
#import <GemsCurrencyManager.h>

@interface GemsStartupController ()<ASWatcher, UITextFieldDelegate>
{
    TGGemsIntroController *_introController;
    TelegramSignupHelper *_signupHelper;
    
    NSString *_verifiedPhoneNumber;
    NSString *_verifiedPhoneNumberHash;
    NSString *_verifiedPhoneNumberCode;
    NSString *_deviceAuth;
    NSString *_userId;
    NSString *_userName;
    NSString *_telegramUserID;
    
    // flags
    BOOL _didRegisterNewUser;
}

@end

@implementation GemsStartupController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(IS_IPAD)
        nibNameOrNil = [nibNameOrNil stringByAppendingString:@"Ipad"];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showIntro];
    
    _signupHelper = [TelegramSignupHelper new];
    
    // prevent in app popups
    TGAppDelegateInstance.bannerEnabled = NO;
    [TGAppDelegateInstance saveSettings];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
}

#pragma mark - launch sequence

- (void)showIntro
{
    [((GemsNavigationController*)self.navigationController) setNavigationBarHidden:YES];
    
    //////////////
    //
    //  Intro
    //
    //////////////
    _introController = [[TGGemsIntroController alloc] initWithNibName:@"GemsIntroController" bundle:GemsUIBundle];
    _introController.completionBlock = ^{
        //////////////
        //
        //  phone verification
        //
        //////////////
        [self pushPhoneVerificationControllerAnimated:YES completion:^{
            
            _deviceAuth = [self deviceAuth];
            
            //////////////
            //
            //  bot auth
            //
            //////////////
            [self showProgressOverlay];
            [self botAuthentication:^(NSString *error, bool wasRegistering) {
                if(error) {
                    [self hideProgressOverlay];
                    [UserNotifications showUserMessage:error];
                    return ;
                }
                //////////////
                //
                //  persist registration
                //
                //////////////
                [self perssistRegistrationData:^{
                    if(wasRegistering) {
                        [self maybeSetInviter];
                    }
                    else {
                        [self hideProgressOverlay];
                        [self callCompletion];
                    }
                }];
            }];
        }];
    };
    [self.navigationController pushViewController:_introController animated:NO];
}

- (void)botAuthentication:(void(^)(NSString *error, bool wasRegistering))completion
{
    BotAuthenticator *auth = [[BotAuthenticator alloc] initWithDeviceAuth:_deviceAuth phoneNumber:_verifiedPhoneNumber ver:API.networking.enviroment.buildNumber];
    [auth authenticate:^(NSError *error, NSString *jwtToken, NSString *gemsId, BOOL wasRegistering) {
        if(error)
        {
            if(completion)
                completion(error.localizedDescription, NO);
            
            [GemsAnalytics track:AnalyticsRegistrationFail args:@{@"reason" : error.localizedDescription}];
        }
        else {
            [API.networking setJwtToken:jwtToken];
            _userId = gemsId;
            _didRegisterNewUser = wasRegistering;
            if(completion)
                completion(nil, wasRegistering);
            
            [Analytics setAnalyticsIdentity:_userId
                                   username:_userName
                                  firstName:_userName
                                   lastName:_userName
                                phoneNumber:_verifiedPhoneNumber
                                  isNewUser:wasRegistering];
        }
        
    }];
}

- (void)pushPhoneVerificationControllerAnimated:(BOOL)animated completion:(void(^)())completion
{
    GemsLoginPhoneController *v = [[GemsLoginPhoneController alloc] init];
    v.disableBackButton = NO;
    v.completionBlock = ^(NSString *verifiedPhoneNumber, NSString *phonenumberHash, NSString *phonnumberCode){
        _verifiedPhoneNumber = [self stripPhonenumberFromAnythingButNumbers:verifiedPhoneNumber];
        _verifiedPhoneNumberHash = phonenumberHash;
        _verifiedPhoneNumberCode = phonnumberCode;
        _telegramUserID = [NSString stringWithFormat:@"%d", TGTelegraphInstance.clientUserId];
        
        TGUser *user = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
        _userName = _NES(user.userName);
        
        if(completion)
            completion();
    };
    [self.navigationController pushViewController:v animated:animated];
}

- (NSString*)randomUsername
{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:20];
    for (NSUInteger i = 0U; i < 10; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    return s;
}

- (NSString*)stripPhonenumberFromAnythingButNumbers:(NSString*)rawPhoneNumber
{
    return [rawPhoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [rawPhoneNumber length])];
}

- (NSString *)deviceAuth
{
    NSString *deviceAuthFromKeychain = getKeychainString(@"GEMS_DEVICE_AUTH", nil);
    if(!deviceAuthFromKeychain) {
        NSString *newDeviceAuth = [CryptoUtils generateNewRandomDeviceAuth];
        setKeychainString(newDeviceAuth, @"GEMS_DEVICE_AUTH", YES);
        return newDeviceAuth;
    }
    return deviceAuthFromKeychain;
}

- (void)perssistRegistrationData:(void(^)())completion
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        CDGemsSystem *gemsSystem = [CDGemsSystem MR_createInContext:localContext];
        gemsSystem.isRegistered = @(1);
        gemsSystem.currencySymbol = @"usd";
        
        CDGemsUser *user = [CDGemsUser MR_createInContext:localContext];
        user.deviceAuth = _deviceAuth;
        user.gemsUserId = _userId;
        user.telegramUserId = @([_telegramUserID intValue]);
        user.userName = _userName;
        user.phoneNumber = _verifiedPhoneNumber;
        user.cntReferrals = 0;
        user.gemsEarned = 0;
        
    } completion:^(BOOL success, NSError *error) {
        if(error) {
            [UserNotifications showUserMessage:error.localizedDescription];
            return ;
        }
        
        // save critical data to keychain
        [[Gems sharedInstance] storeUserDataInKeychain:[CDGemsUser MR_findFirst]];
        
        // set branch identity
        CDGemsUser *user = [CDGemsUser MR_findFirst];
        NSString *gemsId = user.gemsUserId;
        [[Branch getInstance] setIdentity:gemsId]; 
        
        [self showProgressOverlay];
        if(completion)
            completion();
    }];

}

- (void)callCompletion
{
    [Currencies setCurrency:_G.type active:YES reload:YES];
    
    // make sure we show coachmarkrs
    [CoachMarks resetAllCoachMarks];
    
    // refresh balances
    [_G updateBalance:NilCompletionBlock];
    
    [GemsAnalytics track:AnalyticsRegistrationSuccess args:@{}];
    
    if(self.completionBlock)
        self.completionBlock();
}

#pragma mark - set inviter
- (void)maybeSetInviter
{
    [self showProgressOverlay];
    
    // check for referral
    _referrerData = [[Branch getInstance] getFirstReferringParams];
    NSString *referrerGemsId = [_referrerData objectForKey:REFERRER_DATA_ID_KEY];
    if(!referrerGemsId) {
       [self callCompletion];
        return;
    }
    
    // post api
    [API setInviter:referrerGemsId resond:^(GemsNetworkRespond *respond) {
        if([respond hasError])
        {
            [UserNotifications showUserMessage:respond.error.localizedError];
            return ;
        }
        
        [GemsAnalytics track:AnalyticsRegistrationSetInviter args:@{@"gemsid": referrerGemsId}];
        [self hideProgressOverlay];
        [self callCompletion];
    }];
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidChange :(UITextField *)theTextField
{
    if(theTextField.text.length > 0) {
        [self._currentNavigationItem.rightBarButtonItem setEnabled:NO];
    }
    else
        [self._currentNavigationItem.rightBarButtonItem setEnabled:YES];
}

#pragma mark - activity indicator
- (void)showProgressOverlay { [DiamondActivityIndicator showDiamondIndicatorInView:self.navigationController.view]; }
- (void)hideProgressOverlay { [DiamondActivityIndicator hideDiamondIndicatorFromView:self.navigationController.view];}

- (void)removeController:(Class)clss fromNavController:(UINavigationController*)nav
{
    NSMutableIndexSet *arr  = [[NSMutableIndexSet alloc] init];
    for(NSUInteger i =0; i < nav.viewControllers.count; i++) {
        id contr = [nav.viewControllers objectAtIndex:i];
        if([contr isMemberOfClass:clss]) {
            [arr addIndex:i];
        }
    }
    
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray: nav.viewControllers];
    [allViewControllers removeObjectsAtIndexes:arr];
    nav.viewControllers = allViewControllers;
}

@end
