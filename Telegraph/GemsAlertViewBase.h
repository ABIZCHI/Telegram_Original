//
//  GemsAlertView.h
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import <UIKit/UIKit.h>

@interface GemsAlertViewBase : UIView

@property (nonatomic, strong) id alertObject;
@property (nonatomic, copy) void (^closeBlock)();

@end
