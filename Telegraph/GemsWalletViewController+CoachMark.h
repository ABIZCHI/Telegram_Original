//
//  GemsWalletViewController+CoachMark.h
//  GetGems
//
//  Created by alon muroch on 4/7/15.
//
//

#import "GemsWalletViewController.h"

static NSArray* GemsWalletViewControllerCoachMarksIds()
{
    return @[
             @"GemsWalletViewControllerCM#1",
             @"GemsWalletViewControllerCM#2"
             ];
}

@interface GemsWalletViewController (CoachMark)

- (NSArray*)coachMarks;

@end
