//
//  CoachMarksPlayer.h
//  GetGems
//
//  Created by alon muroch on 4/7/15.
//
//

#import <Foundation/Foundation.h>

@interface CoachMarksPlayer : NSObject

- (instancetype) initWithViewController:(UIViewController*)viewController;
- (void)playCoachMarkes:(NSArray*)coachMarks;
- (void)removeAllCoachMarks;

@end
