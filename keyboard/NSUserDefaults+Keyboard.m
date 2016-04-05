//
//  NSUserDefaults+Keyboard.m
//  GetGems
//
//  Created by alon muroch on 03/03/2016.
//
//

#import "NSUserDefaults+Keyboard.h"


static NSString *kTokenForKeyboard                   = @"KeyboardToken";
static NSString *kDidSetPaymentMethod                = @"DidSetPaymentMethod";
static NSString *kVerifiedPhoneNumber                = @"VerifiedPhoneNumber";
static NSString *kTouchIdAuthentication              = @"TouchIdAuthentication";
static NSString *kDidSwitchToPayKeyForTheFirstTime   = @"DidSwitchToPayKeyForTheFirstTime";
static NSString *kUsername                           = @"Username";

static NSString *kAnalyticsIdentity                  = @"kAnalyticsIdentity";

@implementation NSUserDefaults (Keyboard)

- (void)setDidSetPaymentMethod:(BOOL)newVal {
    [self setBool:newVal forKey:kDidSetPaymentMethod];
    [self synchronize];
}
- (BOOL)didSetPaymentMethod {
    return [self boolForKey:kDidSetPaymentMethod];
}

- (void)setDidSwitchToPayKeyForTheFirstTime:(BOOL)newVal {
    [self setBool:newVal forKey:kDidSwitchToPayKeyForTheFirstTime];
    [self synchronize];
}
- (BOOL)didSwitchToPayKeyForTheFirstTime {
    return [self boolForKey:kDidSwitchToPayKeyForTheFirstTime];
}

- (void)setVerifiedPhoneNumber:(NSString*)newVal {
    [self setObject:newVal forKey:kVerifiedPhoneNumber];
    [self synchronize];
}
- (NSString*)verifiedPhoneNumber {
    return [self stringForKey:kVerifiedPhoneNumber];
}

- (void)setTouchIdAuthentication:(BOOL)newVal {
    [self setBool:newVal forKey:kTouchIdAuthentication];
    [self synchronize];
}
- (BOOL)touchIdAuthentication {
    return [self boolForKey:kTouchIdAuthentication];
}

- (void)setUsername:(NSString*)newVal {
    [self setObject:newVal forKey:kUsername];
    [self synchronize];
}
- (NSString*)username {
    NSString *ret = [self stringForKey:kUsername];
    if (!ret) {
        return @"John Doe";
    }
    return ret;
}

- (void)setAnalyticsIdentity:(NSString*)newVal {
    [self setObject:newVal forKey:kAnalyticsIdentity];
    [self synchronize];
}
- (NSString*)analyticsIdentity {
    return [self stringForKey:kAnalyticsIdentity];
}


@end
