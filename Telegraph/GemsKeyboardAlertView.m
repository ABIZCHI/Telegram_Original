//
//  GemsKeyboardAlertView.m
//  GetGems
//
//  Created by alon muroch on 03/03/2016.
//
//

#import "GemsKeyboardAlertView.h"
#import "KbHelper.h"
#import "OnboardingNavigationController.h"
#import "TGAppDelegate.h"

@interface GemsKeyboardAlertView() <OnboardingNavigationControllerProtocol>

@end

@implementation GemsKeyboardAlertView

+ (GemsKeyboardAlertView*)new
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GemsKeyboardAlertView" owner:self options:nil];
    GemsKeyboardAlertView *v = (GemsKeyboardAlertView *)[nib objectAtIndex:0];
    return v;
}

- (void)awakeFromNib
{
    _lblTitle.text = GemsLocalized(@"GemsKbPromotionTitle");
    _lblFirstMsg.text = GemsLocalized(@"GemsKbPromotionMsg1");
    _lblSecondMsg.text = GemsLocalized(@"GemsKbPromotionMsg2");
    
    _btnTellMeMore.layer.borderColor = [[UIColor whiteColor] CGColor];
    _btnTellMeMore.layer.borderWidth = 1.0f;
    _btnTellMeMore.layer.cornerRadius = 10.0f;
    [_btnTellMeMore setTitle:GemsLocalized(@"GemsKbPromotionTellMeMore") forState:UIControlStateNormal];
    
    _btnNotNow.layer.borderColor = [[UIColor whiteColor] CGColor];
    _btnNotNow.layer.borderWidth = 1.0f;
    _btnNotNow.layer.cornerRadius = 10.0f;
    [_btnNotNow setTitle:GemsLocalized(@"GemsKbPromotionNotNow") forState:UIControlStateNormal];
}

- (IBAction)tellMeMorePressed:(id)sender {
    if ([KbHelper didInstallKeyboard]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"OnboardingStoryboard" bundle:nil];
        UINavigationController *nav = [sb instantiateInitialViewController];
        UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"StartUsingPaykeyController"];
        nav.viewControllers = @[vc];
        ((OnboardingNavigationController*)nav).onboardingDelegate = self;
        presentController(nav, YES);
    }
    else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"OnboardingStoryboard" bundle:nil];
        UINavigationController *vc = [sb instantiateInitialViewController];
        ((OnboardingNavigationController*)vc).onboardingDelegate = self;
        presentController(vc, YES);
    }
    
    if(self.closeBlock) {
        self.closeBlock();
    }
}

- (IBAction)notNowPressed:(id)sender {
    if(self.closeBlock) {
        self.closeBlock();
    }
}

#pragma mark - OnboardingNavigationControllerProtocol
- (void)finished:(__weak OnboardingNavigationController *) __unused navController {
    dismissController(YES);
}

@end
