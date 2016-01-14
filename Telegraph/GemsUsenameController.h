//
//  GemsUsenameControllerViewController.h
//  GetGems
//
//  Created by alon muroch on 8/23/15.
//
//

#import "TGUsernameController.h"

@interface GemsUsenameController : TGUsernameController

@property (nonatomic, copy) void (^completionBlock)(NSString *username);

@end
