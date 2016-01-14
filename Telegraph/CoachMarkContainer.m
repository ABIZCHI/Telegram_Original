//
//  CoachMarkContainer.m
//  GetGems
//
//  Created by alon muroch on 4/8/15.
//
//

#import "CoachMarkContainer.h"


@interface CoachMarkContainer()
{
    CoachMarkView *_coachmark;
}

@end

@implementation CoachMarkContainer

- (instancetype)initWithFrame:(CGRect)frame andCoachMark:(CoachMarkView*)coachMarkView
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _coachmark = coachMarkView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        
        self.hidden = YES;
    }
    return self;
}

- (void)tap: (UITapGestureRecognizer *) __unused recognizer
{
    if(self.touchEvent)
        self.touchEvent();
}

- (void)popIn
{
    [self setHidden:NO];
    [self addSubview:[_coachmark popIn]];
    
}

- (void)popOutWithCompletion:(void(^)())completion
{
    [_coachmark popOut];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.7 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
        
        if(completion)
            completion();
    });
}

@end
