//
//  CoachMarks.h
//  GetGems
//
//  Created by alon muroch on 4/7/15.
//
//

#import <Foundation/Foundation.h>

@interface CoachMarks : NSObject

+ (void)showCoachMarksForViewController:(UIViewController*)__unsafe_unretained  viewController;
+ (void)removeAllCoachMarksForViewController:(UIViewController*)__unsafe_unretained  viewController;
+ (void)resetAllCoachMarks;

@end
