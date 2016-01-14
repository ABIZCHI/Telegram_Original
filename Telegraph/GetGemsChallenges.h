//
//  GetGemsChallenges.h
//  GetGems
//
//  Created by alon muroch on 6/24/15.
//
//

#import <Foundation/Foundation.h>
#import <FBSDKShareKit/FBSDKGameRequestContent.h>
#import <FBSDKShareKit/FBSDKGameRequestDialog.h>

#import "GemsAppRating.h"
#import "GemsStoreCommons.h"

// Currencies
#import <CurrencyConst.h>

@interface FBSDKGameRequestDialogCallback : NSObject <FBSDKGameRequestDialogDelegate>

@property (nonatomic, copy) void (^didFailWithError)(NSString *error);
@property (nonatomic, copy) void (^didCompleteWithResults)(NSDictionary *results);

@end

@interface GemsAppRatingCallback : NSObject <GemsAppRatingViewDelegate>

@property (nonatomic, copy) void (^resultBlock)(bool didRate, int rating);

@end


@interface GetGemsChallenges : NSObject

+(instancetype)sharedInstance;

+ (BOOL)launchFollowOnTwitterChallenge;
+ (BOOL)launchFollowOnFacebookChallenge;
+ (void)loginToFacebookAndGetUserDataWithCompletion:(void(^)(NSString *error))completion;
+ (void)shareAppOnFacebookWithCallback:(FBSDKGameRequestDialogCallback *)callback;
+ (void)rateAppWithDidRateCompletion:(void(^)(bool didRate, int rating))completion;

// challenges
+ (void)updateAvailableGetGemsChallenges:(NSArray*)challenges;
+ (NSArray*)availableGetGemsChallenges;
+ (BOOL)challengeAvailable:(GetGemsChallengeType)type;
+ (BOOL)hideChallengeAfterCompletion:(GetGemsChallengeType)type;
+ (DigitalTokenAmount)amountForChallenge:(GetGemsChallengeType)type;

@end
