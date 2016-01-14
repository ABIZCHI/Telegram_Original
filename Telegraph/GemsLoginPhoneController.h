//
//  GemsLoginPhoneController.h
//  GetGems
//
//  Created by alon muroch on 3/12/15.
//
//

#import <Foundation/Foundation.h>
#import "ASWatcher.h"
#import "TGLoginPhoneController.h"

@interface GemsLoginPhoneController : TGLoginPhoneController <ASWatcher>

@property (nonatomic, strong) NSString *baseUserName;

@property (nonatomic, copy) void (^completionBlock)(NSString *verifiedPhoneNumber, NSString *phonenumberHash, NSString *phoneCode);
@property (nonatomic) BOOL disableBackButton;

@end
