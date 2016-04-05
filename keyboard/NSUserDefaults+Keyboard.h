//
//  NSUserDefaults+Keyboard.h
//  GetGems
//
//  Created by alon muroch on 03/03/2016.
//
//

#import <Foundation/Foundation.h>
#import "ExtensionConst.h"

static NSUserDefaults* KBDefaults() {
    return [[NSUserDefaults alloc] initWithSuiteName:appGroupsSuite];
}

@interface NSUserDefaults (Keyboard)

@property (nonatomic, assign) BOOL didSetPaymentMethod;
@property (nonatomic, strong) NSString *verifiedPhoneNumber;
@property (nonatomic, assign) BOOL didSwitchToPayKeyForTheFirstTime;
@property (nonatomic, assign) BOOL touchIdAuthentication;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSString *analyticsIdentity;

@end
