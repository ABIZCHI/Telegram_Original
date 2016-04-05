//
//  KbHelper.h
//  GetGems
//
//  Created by alon muroch on 06/03/2016.
//
//

#import <Foundation/Foundation.h>

@interface KbHelper : NSObject

/**
  * When the app is running and allow full access is turned on it causes the app to crash (bug with iOS).
  * Setting this flag will continue the keybaord onboarding once the user returns.
 */
+ (void)setIsExpectingCrashAfterAllowedFullAccess;
+ (BOOL)finishKeyboardInstallation;

+ (BOOL)didInstallKeyboard;
+ (BOOL)didActivateKeyboard;

@end
