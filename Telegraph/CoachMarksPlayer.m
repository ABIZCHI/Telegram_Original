//
//  CoachMarksPlayer.m
//  GetGems
//
//  Created by alon muroch on 4/7/15.
//
//

#import "CoachMarksPlayer.h"
#import "CoachMarkView.h"
#import "CoachMarkContainer.h"

@interface CoachMarksPlayer()
{
    UIViewController *__unsafe_unretained _viewController;
    NSArray *_coachMarks;
    int _currentPlayingCoachMarkIdx;
    
    CoachMarkContainer *_currentPresentedCoachMark;
}

@end

@implementation CoachMarksPlayer

- (instancetype) initWithViewController:(UIViewController*)__unsafe_unretained viewController
{
    self = [super init];
    if(self) {
        _viewController = viewController;
    }
    return self;
}

- (void)playCoachMarkes:(NSArray*)coachMarks
{
    _coachMarks = coachMarks;
    
    _currentPlayingCoachMarkIdx = -1;
    [self playNextCoachMark];
}

- (void)removeAllCoachMarks
{
    [_currentPresentedCoachMark popOutWithCompletion:nil];
    _coachMarks = nil;
}

static bool playingCoachMark = NO;
- (void)playNextCoachMark
{
    if(playingCoachMark) return;
    
    if(_currentPresentedCoachMark)
        [_currentPresentedCoachMark popOutWithCompletion:nil];
    
    if(_currentPlayingCoachMarkIdx + 1 >= _coachMarks.count) return;
    _currentPlayingCoachMarkIdx ++;
    
    CoachMarkView *next = [_coachMarks objectAtIndex:_currentPlayingCoachMarkIdx];
    if(![self bumpShowedNumberForCoachMarkWithUniqueID:next.uniqueID]) {
        [self playNextCoachMark];
        return;
    }
    
    playingCoachMark = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        TouchEventBlock originalEventBlock = next.touchEvent;
        next.touchEvent = ^(CoachMarkView *cm){
            if(originalEventBlock)
                originalEventBlock(cm);
            else {
                if(_currentPresentedCoachMark.touchEvent)
                    _currentPresentedCoachMark.touchEvent();
            }
        };
        
        _currentPresentedCoachMark = [[CoachMarkContainer alloc] initWithFrame:_viewController.view.frame andCoachMark:next];
        _currentPresentedCoachMark.touchEvent = ^{
            [_currentPresentedCoachMark popOutWithCompletion:^{
                [self playNextCoachMark];
            }];
        };
        
        [_viewController.view addSubview:_currentPresentedCoachMark];
        [_viewController.view bringSubviewToFront:_currentPresentedCoachMark];
        [_currentPresentedCoachMark popIn];
        
        playingCoachMark = NO;
    });
    
}

- (BOOL)bumpShowedNumberForCoachMarkWithUniqueID:(NSString*)uid
{
#if SHOW_COACH_MARKS_ALL_THE_TIME
    return YES;
#else
    NSString *uid_cnt = [uid stringByAppendingString:@"_cnt"];
    NSString *uid_last_pop = [uid stringByAppendingString:@"_last_pop"];
    
    NSInteger cnt = [[NSUserDefaults standardUserDefaults] integerForKey:uid_cnt];
    if(!cnt) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:uid_cnt];
        [[NSUserDefaults standardUserDefaults] setDouble:[NSDate date].timeIntervalSince1970 forKey:uid_last_pop];
        return YES;
    }
    
    if(cnt < 3) {
        NSTimeInterval lastPoped = (NSTimeInterval)[[NSUserDefaults standardUserDefaults] doubleForKey:uid_last_pop];
        if(lastPoped) {
            int d = lastPoped  - [NSDate date].timeIntervalSince1970;
            if(d > -24*60*60) // 24 hours didnt pass
                return NO;
        }
        
        cnt ++;
        [[NSUserDefaults standardUserDefaults] setInteger:cnt forKey:uid_cnt];
        [[NSUserDefaults standardUserDefaults] setDouble:[NSDate date].timeIntervalSince1970 forKey:uid_last_pop];
        
        return YES;
    }
    return NO;
#endif
}

@end
