//
//  GemsLoginProfileController.h
//  GetGems
//
//  Created by alon muroch on 5/17/15.
//
//

#import "TGLoginProfileController.h"

@interface GemsLoginProfileController : TGLoginProfileController

/**custom ending for when logged in
 */
@property (nonatomic, copy) void (^completionBlock)();

@end
