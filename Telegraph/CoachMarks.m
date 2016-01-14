//
//  CoachMarks.m
//  GetGems
//
//  Created by alon muroch on 4/7/15.
//
//

#import "CoachMarks.h"
#import "GemsWalletViewController+CoachMark.h"
#import "CoachMarksPlayer.h"

@implementation CoachMarks

+ (void)showCoachMarksForViewController:(UIViewController*)__unsafe_unretained viewController
{
    NSArray *cm = [self coachMarksForViewController:viewController];
    
    if(!cm) return;
    
    CoachMarksPlayer *player = [[CoachMarksPlayer alloc] initWithViewController:viewController];
    [player playCoachMarkes:cm];
    
    [[self viewControllers] setObject:player forKey:NSStringFromClass([viewController class])];
}

+ (void)removeAllCoachMarksForViewController:(UIViewController*)__unsafe_unretained viewController
{
    CoachMarksPlayer *player = (CoachMarksPlayer *)[[self viewControllers] objectForKey:NSStringFromClass([viewController class])];
    [player removeAllCoachMarks];
    
    [[self viewControllers] removeObjectForKey:[viewController class]];
}

+ (void)resetAllCoachMarks
{
    NSArray *uids = GemsWalletViewControllerCoachMarksIds();
    
    for(NSString* uid in uids)
    {
        NSString *uid_cnt = [uid stringByAppendingString:@"_cnt"];
        NSString *uid_last_pop = [uid stringByAppendingString:@"_last_pop"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:uid_cnt];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:uid_last_pop];
    }
}

+ (NSArray*)coachMarksForViewController:(UIViewController*)__unsafe_unretained viewController
{
    if([viewController isMemberOfClass:GemsWalletViewController.class]) {
        return [((GemsWalletViewController*)viewController) coachMarks];
    }
    
    return nil;
}

static NSMutableDictionary *_viewControllers;
+ (NSMutableDictionary*)viewControllers
{
    if(!_viewControllers) {
        _viewControllers = [[NSMutableDictionary alloc] init];
    }
    return  _viewControllers;
}

@end
