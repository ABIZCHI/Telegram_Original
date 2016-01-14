//
//  CoachMarkContainer.h
//  GetGems
//
//  Created by alon muroch on 4/8/15.
//
//

#import <UIKit/UIKit.h>
#import "CoachMarkView.h"

@interface CoachMarkContainer : UIView

@property (nonatomic, copy) void (^touchEvent)();

- (instancetype)initWithFrame:(CGRect)frame andCoachMark:(CoachMarkView*)coachMarkView;
- (void)popIn;
- (void)popOutWithCompletion:(void(^)())completion;

@end
