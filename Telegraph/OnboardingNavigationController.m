//
//  OnboardingNavigationController.m
//  GetGems
//
//  Created by alon muroch on 03/03/2016.
//
//

#import "OnboardingNavigationController.h"

@interface OnboardingNavigationController ()

@end

@implementation OnboardingNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)signalFinised {
    if (_onboardingDelegate) {
        [_onboardingDelegate finished:self];
    }
}

@end
