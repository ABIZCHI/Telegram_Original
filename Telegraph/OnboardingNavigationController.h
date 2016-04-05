//
//  OnboardingNavigationController.h
//  GetGems
//
//  Created by alon muroch on 03/03/2016.
//
//

#import <UIKit/UIKit.h>

@class OnboardingNavigationController;

@protocol OnboardingNavigationControllerProtocol <NSObject>

- (void)finished:(__weak OnboardingNavigationController *)navController;

@end

@interface OnboardingNavigationController : UINavigationController

@property (nonatomic, strong) id<OnboardingNavigationControllerProtocol> onboardingDelegate;

- (void)signalFinised;

@end
