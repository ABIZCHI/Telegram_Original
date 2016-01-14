//
//  GemsLoginCodeControllerViewController.m
//  GetGems
//
//  Created by alon muroch on 3/12/15.
//
//

#import "GemsLoginCodeController.h"
#import "SGraphObjectNode.h"
#import "TGAppDelegate.h"
#import "TGAlertView.h"
#import "TGSignInRequestBuilder.h"
#import "TGSendCodeRequestBuilder.h"
#import "UIDevice+PlatformInfo.h"
#import "TGPhoneUtils.h"
#import "TGTelegraph.h"
#import "GemsColors.h"
#import "GemsLoginProfileController.h"

@interface GemsLoginCodeController ()
{
    BOOL _newUser;
}

@end

@implementation GemsLoginCodeController

- (id)initWithShowKeyboard:(bool)__unused showKeyboard
               phoneNumber:(NSString *)phoneNumber
             phoneCodeHash:(NSString *)phoneCodeHash
              phoneTimeout:(NSTimeInterval)phoneTimeout
     messageSentToTelegram:(bool)messageSentToTelegram
{
    self = [super initWithShowKeyboard:showKeyboard phoneNumber:phoneNumber phoneCodeHash:phoneCodeHash phoneTimeout:phoneTimeout messageSentToTelegram:NO]; // for SMS
    if (self)
    {
        _newUser = !messageSentToTelegram;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    if(!_newUser)
    {
        // delay to not block SMS sending on telegram servers
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self didNotReceiveCodeButtonPressed]; // force SMS
        });
    }
    
    // change to Gems theme
    self.grayBackground.backgroundColor = [GemsAppearance navigationBackgroundColor];
    self.titleLabel.textColor = [GemsAppearance navigationTextColor];
    self.didNotReceiveCodeButton.titleLabel.textColor = [GemsColors colorWithType:GemsRed];
    
    // customize for iphone 4 + 4s
    if([[UIDevice currentDevice] platformType] == UIDevice4iPhone ||
       [[UIDevice currentDevice] platformType] == UIDevice4SiPhone ||
       ([[UIDevice currentDevice] platformType] == UIDeviceSimulatoriPhone && [[UIScreen mainScreen] bounds].size.height == 480)) {
        self.grayBackground.hidden = YES;
        self.titleLabel.hidden = YES;
        [self setTitle:[TGPhoneUtils formatPhone:self.phoneNumber forceInternational:true]];
    }
}

- (void)actionStageResourceDispatched:(NSString *)__unused path resource:(id)__unused resource arguments:(id)__unused arguments
{
    // stubbing the real [TGLoginCodeController actionStageResourceDispatched:resource:arguments:].
    // We stub them because the returned activation and contactListSynchronizationState calls will load the inactive user controller
    // when loging out and in
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    if ([path isEqualToString:[NSString stringWithFormat:@"/tg/service/auth/signIn/(%d)", self.currentActionIndex]])
    {
        dispatch_async(dispatch_get_main_queue(), ^
       {
           if (resultCode == ASStatusSuccess)
           {
               if ([[((SGraphObjectNode *)result).object objectForKey:@"activated"] boolValue]) {
                   if(self.completionBlock) {
                       self.completionBlock(self.phoneCode);
                       [self.progressWindow dismiss:YES];
                   }
                   else { [TGAppDelegateInstance presentMainController]; }
               }
           }
           else
           {
               self.inProgress = false;
               
               NSString *errorText = GemsLocalized(@"Login.UnknownError");
               bool setDelegate = false;
               
               if (resultCode == TGSignInResultNotRegistered)
               {
                   int stateDate = [[TGAppDelegateInstance loadLoginState][@"date"] intValue];
                   [TGAppDelegateInstance saveLoginStateWithDate:stateDate phoneNumber:self.phoneNumber phoneCode:self.phoneCode phoneCodeHash:self.phoneCodeHash codeSentToTelegram:false firstName:nil lastName:nil photo:nil];
                   
                   errorText = nil;

                   GemsLoginProfileController *v = [[GemsLoginProfileController alloc] initWithShowKeyboard:NO phoneNumber:self.phoneNumber phoneCodeHash:self.phoneCodeHash phoneCode:self.phoneCode];
                   v.completionBlock = ^{
                       if(self.completionBlock) {
                           self.completionBlock(self.phoneCode);
                       }
                   };
                   [self pushControllerRemovingSelf:v];
                   
               }
               else if (resultCode == TGSignInResultTokenExpired)
               {
                   errorText = GemsLocalized(@"Login.CodeExpiredError");
                   setDelegate = true;
               }
               else if (resultCode == TGSignInResultFloodWait)
               {
                   errorText = GemsLocalized(@"Login.CodeFloodError");
               }
               else if (resultCode == TGSignInResultInvalidToken)
               {
                   errorText = GemsLocalized(@"Login.InvalidCodeError");
               }
               
               if (errorText != nil)
               {
                   TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:errorText delegate:setDelegate ? self : nil cancelButtonTitle:GemsLocalized(@"Common.OK") otherButtonTitles:nil];
                   [alertView show];
               }
           }
       });
    }
    else if ([path hasPrefix:@"/tg/service/auth/sendCode/"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
       {
           [self setInProgress:false];

           if (self.messageSentToTelegram)
           {
               if (resultCode == ASStatusSuccess)
               {
                   int stateDate = [[TGAppDelegateInstance loadLoginState][@"date"] intValue];
                   [TGAppDelegateInstance saveLoginStateWithDate:stateDate phoneNumber:self.phoneNumber phoneCode:nil phoneCodeHash:self.phoneCodeHash codeSentToTelegram:false firstName:nil lastName:nil photo:nil];
                   
                   { // We already force SMS
//                       GemsLoginCodeController *controller = [[GemsLoginCodeController alloc] initWithShowKeyboard:(self.codeField.isFirstResponder) phoneNumber:self.phoneNumber phoneCodeHash:self.phoneCodeHash phoneTimeout:self.phoneTimeout messageSentToTelegram:false];
//                       controller.completionBlock = self.completionBlock;
//                       
//                       [self.navigationController pushViewController:controller animated:true];

                   }
               }
               else
               {
                   NSString *errorText = GemsLocalized(@"Login.NetworkError");
                   
                   if (resultCode == TGSendCodeErrorInvalidPhone)
                       errorText = GemsLocalized(@"Login.InvalidPhoneError");
                   else if (resultCode == TGSendCodeErrorFloodWait)
                       errorText = GemsLocalized(@"Login.CodeFloodError");
                   else if (resultCode == TGSendCodeErrorNetwork)
                       errorText = GemsLocalized(@"Login.NetworkError");
                   
                   TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:errorText delegate:nil cancelButtonTitle:GemsLocalized(@"Common.OK") otherButtonTitles:nil];
                   [alertView show];
               }
           }
           else
           {
               if (resultCode == ASStatusSuccess)
               {
//                   if(!_newUser) {
//                       [UIView animateWithDuration:0.2 animations:^
//                        {
//                            self.requestingCallLabel.alpha = 0.0f;
//                        }];
//                       
//                       [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^
//                        {
//                            self.callSentLabel.alpha = 1.0f;
//                        } completion:nil];
//                   }
               }
               else
               {
                   NSString *errorText = GemsLocalized(@"Login.NetworkError");
                   
                   if (resultCode == TGSendCodeErrorInvalidPhone)
                       errorText = GemsLocalized(@"Login.InvalidPhoneError");
                   else if (resultCode == TGSendCodeErrorFloodWait)
                       errorText = GemsLocalized(@"Login.CodeFloodError");
                   else if (resultCode == TGSendCodeErrorNetwork)
                       errorText = GemsLocalized(@"Login.NetworkError");
                   
                   TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:errorText delegate:nil cancelButtonTitle:GemsLocalized(@"Common.OK") otherButtonTitles:nil];
                   [alertView show];
               }
           }
       });
    }
}


@end
