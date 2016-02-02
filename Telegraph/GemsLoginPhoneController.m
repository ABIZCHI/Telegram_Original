//
//  GemsLoginPhoneController.m
//  GetGems
//
//  Created by alon muroch on 3/12/15.
//
//

#import "GemsLoginPhoneController.h"
#import "SGraphObjectNode.h"
#import "TGAppDelegate.h"
#import "GemsLoginCodeController.h"
#import "TGAlertView.h"
#import "TGSendCodeRequestBuilder.h"
#import "UIDevice+PlatformInfo.h"

// GemsCore
#import <GemsCore/CryptoUtils.h>
#import <GemsCore/GemsAnalytics.h>

@interface GemsLoginPhoneController()
{
    NSString *_verifiedPhoneNumber;
}

@end

@implementation GemsLoginPhoneController

- (void)loadView
{
    [super loadView];
    
    // change to Gems theme
    self.grayBackground.backgroundColor = [GemsAppearance navigationBackgroundColor];
    self.titleLabel.textColor = [GemsAppearance navigationTextColor];
    
    // customize for iphone 4 + 4s
    if([[UIDevice currentDevice] platformType] == UIDevice4iPhone ||
       [[UIDevice currentDevice] platformType] == UIDevice4SiPhone ||
       ([[UIDevice currentDevice] platformType] == UIDeviceSimulatoriPhone && [[UIScreen mainScreen] bounds].size.height == 480)) {
        self.grayBackground.hidden = YES;
        self.titleLabel.hidden = YES;
        [self setTitle:GemsLocalized(@"Login.PhoneTitle")];
    }
    
    [GemsAnalytics track:AnalyticsRegistrationSetPhoneView args:@{}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(_disableBackButton)
        self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)_commitNextButtonPressed
{
    [super _commitNextButtonPressed];
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    if ([path isEqualToString:[NSString stringWithFormat:@"/tg/service/auth/sendCode/(%d)", self.currentActionIndex]])
    {
        dispatch_async(dispatch_get_main_queue(), ^
       {
           self.inProgress = false;
           
           if (resultCode == ASStatusSuccess)
           {
               NSString *phoneCodeHash = [((SGraphObjectNode *)result).object objectForKey:@"phoneCodeHash"];
               
               NSTimeInterval phoneTimeout = (((SGraphObjectNode *)result).object)[@"callTimeout"] == nil ? 60 : [(((SGraphObjectNode *)result).object)[@"callTimeout"] intValue];
               
               bool messageSentToTelegram = [(((SGraphObjectNode *)result).object)[@"messageSentToTelegram"] intValue];
               
               
               
               [TGAppDelegateInstance saveLoginStateWithDate:(int)CFAbsoluteTimeGetCurrent() phoneNumber:[[NSString alloc] initWithFormat:@"%@|%@", self.countryCodeField.text, self.phoneField.text] phoneCode:nil phoneCodeHash:phoneCodeHash codeSentToTelegram:messageSentToTelegram firstName:nil lastName:nil photo:nil];
               
               // gems - custom exit point
               GemsLoginCodeController *codeLoginController = [[GemsLoginCodeController alloc] initWithShowKeyboard:(self.countryCodeField.isFirstResponder || self.phoneField.isFirstResponder) phoneNumber:self.phoneNumber phoneCodeHash:phoneCodeHash phoneTimeout:phoneTimeout messageSentToTelegram:messageSentToTelegram];
               codeLoginController.completionBlock = ^(NSString *phoneCode){
                   if(self.completionBlock) {
                       _verifiedPhoneNumber = [[NSString alloc] initWithFormat:@"%@%@", self.countryCodeField.text, self.phoneField.text];
                       
                       NSLog(@"Telegram phone verified: %@", _verifiedPhoneNumber);
                       [GemsAnalytics track:AnalyticsRegistrationPhoneVerification args:@{}];
                       
                       [self.progressWindow dismiss:YES];
                       
                       if(self.completionBlock)
                           self.completionBlock(_verifiedPhoneNumber, phoneCodeHash, phoneCode);
                   }
               };
               
               [self.navigationController pushViewController:codeLoginController animated:true];
           }
           else
           {
               NSString *errorText = GemsLocalized(@"Login.UnknownError");
               
               if (resultCode == TGSendCodeErrorInvalidPhone)
                   errorText = GemsLocalized(@"Login.InvalidPhoneError");
               else if (resultCode == TGSendCodeErrorFloodWait)
                   errorText = GemsLocalized(@"Login.CodeFloodError");
               else if (resultCode == TGSendCodeErrorNetwork)
                   errorText = GemsLocalized(@"Login.NetworkError");
               
               TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:errorText delegate:nil cancelButtonTitle:GemsLocalized(@"Common.OK") otherButtonTitles:nil];
               [alertView show];
           }
       });
    }
}

@end
