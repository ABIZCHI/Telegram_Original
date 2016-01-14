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
#import "UserNotifications.h"
#import "DiamondActivityIndicator.h"
#import "TGAppDelegate.h"
#import "TGImageUtils.h"
#import "SGraphObjectNode.h"
#import "TGTelegraph.h"
#import "CoachMarks.h"

#import "TGGemsAlertExecutor.h"
#import "GemsAlertCenter.h"
#import "GemsPassphraseReminderAlert.h"

#import "GetGemsChallenges.h"

#import "GemsAnalytics.h"

#import "GemsAppRating.h"
#import "GemAppRatingStandardPolicy.h"
#import "GemsAppRatingStandardView.h"

#import "BotAuthenticator.h"
#import <Branch.h>
#import "NSURL+GemsReferrals.h"

// netwokring
#import <GemsNetworking.h>

// GemsUI
#import <GemsUI.h>
#import <BtcShowPassphraseController.h>
#import <GemsPinCodeView.h>
#import <GemsWalletViewController.h>
#import <GemsStoreController.h>

// GemsCore
#import <GemsCore/GemsLocalization.h>

#define WALLET_NEEDS_POP_UP_BACKUP_KEY @"WALLET_NEEDS_POP_UP_BACKUP_KEY"

@implementation TGGems

- (void)didBecomeActiveUIPrompts
{
    [self showBackupDialogOnlyIfNeeded];
    
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
     *
     *  FOR TESTING 13.10.15
     *
     *  We try and solve a bug where users send API calls without a jwt token and they cann't 
     *  resolve that state by requesting a new token.
     *  We send this API call to notify such users to contact the support
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [API getGemsBalance:^(GemsNetworkRespond *respond) {
            if(respond.hasError && [respond.error.errorCode isEqualToString:@"JWT_NOT_FOUNDX"]) {
                [UserNotifications showUserMessage:respond.error.localizedError];
            }
        }];

    });
}

- (void)setupNetworkingAuthenticator
{
    // set authentication service for networking
    // only if registered already, if not do it on registration
    if([self isRegistered])
    {
        CDGemsUser *user = [CDGemsUser MR_findFirst];
        BotAuthenticator *auth = [[BotAuthenticator alloc] initWithDeviceAuth:user.deviceAuth phoneNumber:user.phoneNumber ver:API.networking.enviroment.buildNumber];
        [API.networking.enviroment setAuthenticator:auth];
    }
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
                                      [TGAppDelegateInstance pushViewController:v animated:YES];
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
    [TGAppDelegateInstance dismissViewControllerAnimated:YES];
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

@end
