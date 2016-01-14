//
//  GemsLoginProfileController.m
//  GetGems
//
//  Created by alon muroch on 5/17/15.
//
//

#import "GemsLoginProfileController.h"
#import "TGAppDelegate.h"
#import "UIDevice+PlatformInfo.h"

// GemsCore
#import <GemsAnalytics.h>
#import <GemsLocalization.h>

// GemsUI
#import <GemsAppearance.h>

@interface GemsLoginProfileController ()

@end

@implementation GemsLoginProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.grayBackground.backgroundColor = [GemsAppearance navigationBackgroundColor];
    self.titleLabel.textColor = [GemsAppearance navigationTextColor];
    
    // customize for iphone 4 + 4s
    if([[UIDevice currentDevice] platformType] == UIDevice4iPhone ||
       [[UIDevice currentDevice] platformType] == UIDevice4SiPhone ||
       ([[UIDevice currentDevice] platformType] == UIDeviceSimulatoriPhone && [[UIScreen mainScreen] bounds].size.height == 480)) {
        self.grayBackground.hidden = YES;
        self.titleLabel.hidden  = YES;
        [self setTitle:GemsLocalized(@"Login.InfoTitle")];
    }
    
    [GemsAnalytics track:AnalyticsRegistrationEnterDisplayName args:@{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)completion
{
    if(self.completionBlock) {
        self.completionBlock();
    }
    else { [TGAppDelegateInstance presentMainController]; }
}

@end
