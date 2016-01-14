//
//  FBFacade.m
//  GetGems
//
//  Created by alon muroch on 7/6/15.
//
//

#import "FacebookSDKWrapper.h"
#import <FBSDKCoreKit/FBSDKConstants.h>
#import <FBSDKShareKit/FBSDKAppInviteContent.h>
#import <FBSDKShareKit/FBSDKAppInviteDialog.h>


#define ME_INFO_KEY @"FB_ME_INFO_KEY"

#define BASE_READ_PERMISSIONS @[@"public_profile", @"user_friends"]

#define FB_ME_GRAPH @"me"
#define FB_INVITABLE_FRIENDS_GRAPH @"/me/invitable_friends?limit=50"

@implementation NSError (Facebook)

- (NSString*)fbErrorMessage
{
    NSDictionary *e1 = self.userInfo[FBSDKGraphRequestErrorParsedJSONResponseKey];
    NSDictionary *e2 = e1[@"body"];
    NSDictionary *e3 = e2[@"error"];
    NSString *error = e3[@"message"];
    
    return error;
}

@end

@interface FacebookSDKWrapper() <FBSDKAppInviteDialogDelegate>
@end

@implementation FacebookSDKWrapper

+ (BOOL)loggedIn
{
    return [FBSDKAccessToken currentAccessToken] != nil;
}

+ (void)loginForBasicReadPermissionsWithCompletion:(void(^)(NSString *error, NSArray *deniedPermissions))completion
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:BASE_READ_PERMISSIONS handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            if(completion)
                completion([error fbErrorMessage], nil);
        } else if (result.isCancelled) {
            if(completion)
                completion(@"Cancelled Permission Request", nil);
        } else if(result.declinedPermissions.count > 0) {
            if(completion)
                completion(nil, [result.declinedPermissions allObjects]);
        }
        else {
            
            [self fetchMeInfoWithCompletion:^(NSString *error, id me) {
                if (error) {
                    if(completion)
                        completion(error, nil);
                }
                else
                {
                    [self storeMeInfo:(NSDictionary*)me];
                    if(completion)
                        completion(nil, nil);
                }
            }];
        }
    }];
}

+ (void)fetchMeInfoWithCompletion:(void(^)(NSString *error, id me))completion
{
    if ([self loggedIn]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:FB_ME_GRAPH parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if(completion)
                 completion([error fbErrorMessage], result);
         }];
    }
}

+ (void)fetchInvitablefriendsWithCompletion:(void(^)(NSString *error, NSArray *invitableFriends))completion
{
    if (![self loggedIn])
    {
        completion(nil, nil);
        return;
    }
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:FB_INVITABLE_FRIENDS_GRAPH
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if(completion)
            completion([error fbErrorMessage], result[@"data"]);
    }];
}

+ (void)logout
{
    [[FBSDKLoginManager new] logOut];
}

#pragma mark - defaults
+ (void)storeMeInfo:(NSDictionary*)me
{
    [[NSUserDefaults standardUserDefaults] setObject:me forKey:ME_INFO_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary*)meInfo
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:ME_INFO_KEY];
}

#pragma mark - getters
+ (int64_t)userId
{
    if ([self loggedIn])
       return [[self meInfo] objectForKey:@"id"];
    else
        return 0;
}

@end
