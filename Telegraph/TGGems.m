//
//  TGGems.m
//  GetGems
//
//  Created by alon muroch on 7/8/15.
//
//

#import "TGGems.h"
#import "TGGemsWallet.h"
#import "ActionStage.h"
#import "TGAppDelegate.h"
#import "TGImageUtils.h"
#import "SGraphObjectNode.h"
#import "TGTelegraph.h"
#import "CoachMarks.h"
#import "TGGemsAlertExecutor.h"
#import "GemsAlertCenter.h"
#import "GemsPassphraseReminderAlert.h"
#import "GetGemsChallenges.h"
#import "BotAuthenticator.h"
#import <Branch/Branch.h>
#import "GemsWalletViewController.h"
#import "GemsStoreController.h"
#import "ExtensionConst.h"
#import "GemsKeyboardAlert.h"
#import "KbHelper.h"
#import "OnboardingNavigationController.h"
#import "NSUserDefaults+Keyboard.h"
#import "InstructionsController.h"
#import "KbHelper.h"

// netwokring
#import <GemsNetworking/GemsNetworking.h>

// Advertising
#import "LDAdvertisingManager.h"

// GemsUI
#import <GemsUI/GemsUI.h>
#import <GemsUI/BtcShowPassphraseController.h>
#import <GemsUI/GemsPinCodeView.h>
#import <GemsUI/UserNotifications.h>
#import <GemsUI/DiamondActivityIndicator.h>
#import <GemsUI/GemsAppRating.h>
#import <GemsUI/GemAppRatingStandardPolicy.h>
#import <GemsUI/GemsAppRatingStandardView.h>

// GemsCore
#import <GemsCore/GemsLocalization.h>
#import <GemsCore/GemsAnalytics.h>
#import <GemsCore/NSURL+GemsReferrals.h>

#define WALLET_NEEDS_POP_UP_BACKUP_KEY @"WALLET_NEEDS_POP_UP_BACKUP_KEY"

@interface TGGems() <OnboardingNavigationControllerProtocol>
@end

@implementation TGGems

- (id)init {
    self = [super init];
    if(self) {
        
        /**
          * There is a db corruption occuring when moving from the old tg code to the new tg code version 3.2.1
          * So simply drop the old db and let it upload everything from scratch
         */
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"didMoveToNewTelegramCode"]) {
            [[TGDatabase instance] dropDatabase];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"didMoveToNewTelegramCode"];
        }
    }
    return self;
}

- (void)didBecomeActiveUIPrompts
{
    _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
    [ActionStageInstance() watchForPaths:@[
                                           @"/tg/userdatachanges",
                                           @"/tg/userpresencechanges",
                                           @"/tg/applyUsername/"
                                           ] watcher:self];
    
    // Alert Center
    TGGemsAlertExecutor *executor = [[TGGemsAlertExecutor alloc] init];
    GemsAlertCenter *c = [GemsAlertCenter sharedInstance];
    [c setExecutor:executor];
    
    // app rating
    GemAppRatingStandardPolicy *policy = [GemAppRatingStandardPolicy new];
    [policy appLaunched];
    [[GemsAppRating sharedInstance] setRatingViewClass:[GemsAppRatingStandardView class]];
    [[GemsAppRating sharedInstance] setPolicy:policy];
    if([c getAllPendingAlerts].count == 0)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if([[GemsAppRating sharedInstance].policy shouldRateApp]) {
                [GemsAnalytics track:AnalyticsUserAppRatePopup args:@{@"origin" : @"auto"}];
                [GetGemsChallenges rateAppWithDidRateCompletion:NilCompletionBlock];
            }
        });
    
    /**
     *  We try and set the user's inviter every startup to overcome
     *  some referrals issues
     */
    [self tryAndSetInviter];
    
    /**
      * Used for app extension. So to no upload GemsCore we cache the referral link
      * to a shared NSUserDefaults suite
     */
    [NSURL urlWithMyUniqueReferralLinkCompletion:^(NSURL *url, NSError *error) {
        if (!error) {
            [self cacheReferralUrlToDefaults:url];
        }
    }];
    
    [self showBackupDialogOnlyIfNeeded];
    [self showKebyoardPromotionOnlyIfNeeded];
    
    
    // see kbHelper:setIsExpectingCrashAfterAllowedFullAccess
    if([KbHelper finishKeyboardInstallation]) {
        [self continueKeyboardSetup];
    }
    
    // for kb extension
    CDGemsUser *user = [CDGemsUser MR_findFirst];
    [KBDefaults() setAnalyticsIdentity:user.gemsUserId];
    [KBDefaults() setVerifiedPhoneNumber:user.phoneNumber];
    [KBDefaults() setUsername:user.userName];
}

- (void)continueKeyboardSetup {
    if([TGAppDelegateInstance.rootController.detailNavigationController.presentedViewController class] != [OnboardingNavigationController class]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"OnboardingStoryboard" bundle:nil];
        UINavigationController *nav = [sb instantiateInitialViewController];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"StartUsingPaykeyController"];
        nav.viewControllers = @[vc];
        ((OnboardingNavigationController*)nav).onboardingDelegate = self;
        presentController(nav, false);
    }
}

- (void)setupNetworkingAuthenticator
{
    
    [[LDAdvertisingManager sharedManager] setupAdvertising];
    
    // set authentication service for networking
    // only if registered already, if not do it on registration
    if([self isRegistered])
    {
        CDGemsUser *user = [CDGemsUser MR_findFirst];
        BotAuthenticator *auth = [[BotAuthenticator alloc] initWithDeviceAuth:user.deviceAuth phoneNumber:user.phoneNumber ver:API.networking.enviroment.buildNumber];
        [API.networking.enviroment setAuthenticator:auth];
    }
    
    API.networking.userDefaultsGroup = appGroupsSuite;
}

- (void)doLogoutWithCompletion:(void(^)())completion
{
    [CoachMarks resetAllCoachMarks];
    
    // controllers cleanup
    [GemsWalletViewController logoutCleanup];
    [GemsStoreController logoutCleanup];
    
    [self resetBackupDialog];
    
    [[GemsAppRating sharedInstance].policy reset];
    
    [super doLogoutWithCompletion:completion];
}

- (void)resetBackupDialog
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:WALLET_NEEDS_POP_UP_BACKUP_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showBackupDialogOnlyIfNeeded
{
    if(![GEMS isRegistered]) return;
    if(![_B isActive]) return;
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    BOOL didShow = [defs boolForKey:WALLET_NEEDS_POP_UP_BACKUP_KEY];
    if(didShow) return;
    
    DigitalTokenAmount balance = [_B balance];
    if(balance == 0) return;
    
    [defs setBool:YES forKey:WALLET_NEEDS_POP_UP_BACKUP_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    GemsPassphraseReminderAlert *alert = [GemsPassphraseReminderAlert new];
    [[GemsAlertCenter sharedInstance] addAlertsToDefaults:@[alert]];
}

- (void)showKebyoardPromotionOnlyIfNeeded
{
    if(![GEMS isRegistered]) return;
    
    if (![KbHelper didInstallKeyboard]) {
        BOOL didShowOnce = [[NSUserDefaults standardUserDefaults] boolForKey:@"didShowKbPromotionOnce"];
        if (didShowOnce) {
            NSTimeInterval ti = [[NSUserDefaults standardUserDefaults] doubleForKey:@"lastKbPromotion"];
            NSInteger cntShows = [[NSUserDefaults standardUserDefaults] integerForKey:@"kbPromotionConsecutiveShows"];
            NSTimeInterval tiWait = 0;
            if (cntShows < 3) {
                tiWait = 60 * 60 * 24 /* wait a day */;
            }
            else {
                tiWait = 60 * 60 * 24 * 7 /* wait a week */;
            }
            
            if ([[NSDate date] timeIntervalSince1970] - ti < tiWait) {
                return;
            }
            
            // add counters
            NSInteger newCnt = cntShows + 1;
            [[NSUserDefaults standardUserDefaults] setInteger:newCnt forKey:@"kbPromotionConsecutiveShows"];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"kbPromotionConsecutiveShows"];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"didShowKbPromotionOnce"];
        }
        
        GemsKeyboardAlert *alert = [GemsKeyboardAlert new];
        [[GemsAlertCenter sharedInstance] addAlertToDefaults:alert];
        [[GemsAlertCenter sharedInstance] executeAllPendingAlerts];
        
        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:@"lastKbPromotion"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"didShowKbPromotionOnce"]; // reset until the next time
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)showPassphraseRecoveryView
{
    GemsPinCodeView *pincodeView = [GemsPinCodeView new];
    CDGemsUser *user = [CDGemsUser MR_findFirst];
    
    [UserNotifications showUserMessage:GemsLocalized(@"GemsDontShowPhraseText1") afterOk:^{
        if(user.pinCodeHash) {
            [pincodeView authenticatePin:user.pinCodeHash
                               WithTitle:@""
                                 message:GemsLocalized(@"ConfirmWalletPinCode")
                              completion:^(BOOL isVerified, NSDictionary *data, NSString *errorString) {
                                  if(isVerified)
                                  {
                                      BtcShowPassphraseController *v = [BtcShowPassphraseController newForMode:BtcShowPassControllerShow];
                                      v.displayPassphrase = [_B passphrase];
                                      if(IS_IPAD)
                                          [v setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closeShowPhraseController)]];
                                      pushController(v, YES);
                                  }
                              }];
        }
        else {
            [UserNotifications showUserMessage:@"No pincode was set, can't show passphrase"];
        }
    }];
}

- (void)closeShowPhraseController
{
    dismissController(YES);
}

- (void)cacheReferralUrlToDefaults:(NSURL*)url {
    NSUserDefaults *def = [[NSUserDefaults alloc] initWithSuiteName:appGroupsSuite];
    [def setObject:[url absoluteString] forKey:cachedReferralLink];
}

#pragma mark ASwatch
- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:@"/tg/userdatachanges"] || [path isEqualToString:@"/tg/userpresencechanges"] || [path hasPrefix:@"/tg/applyUsername/"])
    {
        NSArray *users = ((SGraphObjectNode *)resource).object;
        
        for (TGUser *user in users)
        {
            if (user.uid == TGTelegraphInstance.clientUserId)
            {
                // do not do anything
                break;
            }
        }
    }
}

#pragma mark - set inviter
- (void)tryAndSetInviter {
    // check for referral
    NSDictionary *referrerData = [[Branch getInstance] getFirstReferringParams];
    NSString *referrerGemsId = referrerData[REFERRER_DATA_ID_KEY];
    if(!referrerGemsId) {
        return;
    }
    
    BOOL didSetUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"INVITER_SET_FLAG"];
    if(didSetUser) return;
    
    // post api
    [API setInviter:referrerGemsId resond:^(GemsNetworkRespond *respond) {
        if([respond hasError]) {
            if([respond.error.errorCode isEqualToString:@"INVITER_ALREADY_SET"])
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"INVITER_SET_FLAG"];
        }
    }];
}

#pragma mark - OnboardingNavigationControllerProtocol
- (void)finished:(__weak OnboardingNavigationController *) __unused navController {
    dismissController(YES);
}

@end
