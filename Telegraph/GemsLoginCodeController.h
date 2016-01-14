//
//  GemsLoginCodeControllerViewController.h
//  GetGems
//
//  Created by alon muroch on 3/12/15.
//
//

#import "TGLoginCodeController.h"

@interface GemsLoginCodeController : TGLoginCodeController

/**custom ending for when logged in
 */
@property (nonatomic, copy) void (^completionBlock)(NSString *phoneCode);

@end
