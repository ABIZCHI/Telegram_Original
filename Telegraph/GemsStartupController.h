//
//  GemsLoginController.h
//  GetGems
//
//  Created by alon muroch on 3/30/15.
//
//

#import "TGViewController.h"

@interface GemsStartupController : TGViewController

/**Will be called once singin/ signup flow is finished.
 */
@property (nonatomic, copy) void (^completionBlock)();

@property(nonatomic, strong) NSDictionary *referrerData;

@end
