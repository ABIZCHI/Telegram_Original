//
//  KbHelper.m
//  GetGems
//
//  Created by alon muroch on 06/03/2016.
//
//

#import "KbHelper.h"
#import "NSUserDefaults+Keyboard.h"
#import "ExtensionConst.h"

@implementation KbHelper

+ (BOOL)didInstallKeyboard {
    NSString *bundleId = [NSString stringWithFormat:@"%@.keyboard", [[NSBundle mainBundle] bundleIdentifier]];
    NSArray *kbs = [[NSUserDefaults standardUserDefaults] arrayForKey:@"AppleKeyboards"];
    for(NSString *s in kbs) {
        if ([s isEqualToString:bundleId]) {
            return true;
        }
    }
    
    return false;
}

+ (BOOL)didActivateKeyboard {
    return [KBDefaults() didSwitchToPayKeyForTheFirstTime];
}

+ (void)setIsExpectingCrashAfterAllowedFullAccess {
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"IsExpectingCrashAfterAllowedFullAccess"];
}

+ (BOOL)finishKeyboardInstallation {
    BOOL ret = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsExpectingCrashAfterAllowedFullAccess"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"IsExpectingCrashAfterAllowedFullAccess"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return ret;
}

@end
