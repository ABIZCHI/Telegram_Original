//
//  FBFacade.h
//  GetGems
//
//  Created by alon muroch on 7/6/15.
//
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface NSError (Facebook)

- (NSString*)fbErrorMessage;

@end

@interface FacebookSDKWrapper : NSObject


+ (BOOL)loggedIn;
+ (int64_t)userId;
+ (void)loginForBasicReadPermissionsWithCompletion:(void(^)(NSString *error, NSArray *deniedPermissions))completion;
+ (void)logout;
+ (void)fetchInvitablefriendsWithCompletion:(void(^)(NSString *error, NSArray *invitableFriends))completion;

@end
