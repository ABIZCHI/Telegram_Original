//
//  GetGemsChallenges.m
//  GetGems
//
//  Created by alon muroch on 6/24/15.
//
//

#import "GetGemsChallenges.h"
#import "FacebookSDKWrapper.h"
#import "GemsTransactionsCommons.h"

// GemsUI
#import <GemsUI/GemsAppRatingStandardView.h>

// GemsCore
#import <GemsCore/GemsCommons.h>
#import <GemsCore/GemsAnalytics.h>

static NSString const * AvailableChallengesKey = @"AvailableChallengesKey";
static NSString const * AvailableChallengesWereSetKey = @"AvailableChallengesWereSetKey";

@implementation FBSDKGameRequestDialogCallback

- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didCompleteWithResults:(NSDictionary *)results
{
    if(_didCompleteWithResults)
        _didCompleteWithResults(results);
}

- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didFailWithError:(NSError *)error
{
    if(_didFailWithError)
        _didFailWithError([error fbErrorMessage]);
}

- (void)gameRequestDialogDidCancel:(FBSDKGameRequestDialog *)gameRequestDialog
{
    NSLog(@"");
}

@end


@implementation GemsAppRatingCallback

#pragma mark - GemsAppRatingViewDelegate

- (void)appRating:(GemsAppRatingView*)appRatingView didRateWithRating:(int)rating
{
    if(rating == 0) {
        [GemsAnalytics track:AnalyticsUserAppRateDismiss args:@{@"stage" : @"before rating"}];
        [appRatingView close];
    }
    
    if(rating > 0)
        [GemsAnalytics track:AnalyticsUserAppRateRatingSelected args:@{@"stars" : [@(rating) stringValue]}];
    
    if(rating == 5) {
        [GemsAnalytics track:AnalyticsUserAppRateAction args:@{@"type" : @"store"}];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=942306232&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [appRatingView close];
        });
    }
    
    if(rating > 0 && rating < 5)
    {
        if([appRatingView class] == [GemsAppRatingStandardView class])
        {
            [(GemsAppRatingStandardView*)appRatingView askIfUserWillSendUsMail];
        }
        else
            [appRatingView close];
    }
    
    if(rating > 0)
        [appRatingView.gemsRatingManager.policy markRated:rating];
    
    if(self.resultBlock)
        self.resultBlock(rating > 0 ? YES:NO, rating);
}

- (void)appRating:(GemsAppRatingView*)appRatingView didChooseToSendEmailFeedback:(BOOL)didChooseToSendEmailFeedback
{
    if([@(didChooseToSendEmailFeedback) stringValue])
        [GemsAnalytics track:AnalyticsUserAppRateAction args:@{@"type" : @"feedback"}];

}

@end

@implementation GetGemsChallenges

+ (BOOL)launchFollowOnTwitterChallenge
{
    // open the Twitter App
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_APP_URI(GEMS_TWITTER_NAME)]]) {
    
        // opening the app didn't work - let's open Safari
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_URL(GEMS_TWITTER_NAME)]]) {
            
            return !Successfull;
        }
    }

    return Successfull; 
}

+ (BOOL)launchFollowOnFacebookChallenge
{
    // open the Twitter App
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:FACEBOOK_APP_URI(GEMS_FACEBOOK_PAGE_ID)]]) {
        
        // opening the app didn't work - let's open Safari
        if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:FACEBOOK_URL(GEMS_FACEBOOK_PAGE_NAME)]]) {
            
            return !Successfull;
        }
    }
    
    return Successfull;
}

+ (void)loginToFacebookAndGetUserDataWithCompletion:(void(^)(NSString *error))completion
{
    [FacebookSDKWrapper loginForBasicReadPermissionsWithCompletion:^(NSString *error, NSArray *deniedPermissions) {
        if(error)
        {
            if (completion)
                completion(error);
            return ;
        }
        
        if(deniedPermissions.count > 0)
        {
            if (completion)
                completion(@"Not all permission were granted");
            return;
        }
        
        if(completion)
            completion(nil);
    }];
}

+ (void)shareAppOnFacebookWithCallback:(FBSDKGameRequestDialogCallback *)callback
{
    [FacebookSDKWrapper fetchInvitablefriendsWithCompletion:^(NSString *error, NSArray *invitableFriends) {
        if(error)
        {
            if(callback.didFailWithError)
                callback.didFailWithError(error);
            return ;
        }
        
        NSMutableArray *recipients = [[NSMutableArray alloc] init];
        for(NSDictionary *d in invitableFriends)
        {
            [recipients addObject:d[@"id"]];
        }
        
        FBSDKGameRequestContent *gameRequestContent = [[FBSDKGameRequestContent alloc] init];
        gameRequestContent.message = @"Take this bomb tdddory!";
        gameRequestContent.recipients = recipients;
        
        [FBSDKGameRequestDialog showWithContent:gameRequestContent delegate:callback];
        
    }];
}

+ (void)rateAppWithDidRateCompletion:(void(^)(bool didRate, int rating))completion
{
    GemsAppRatingCallback *callback = [GemsAppRatingCallback new];
    callback.resultBlock = completion;
    [GemsAppRating sharedInstance].ratingView.ratingDelegate = callback;
    [[GemsAppRating sharedInstance].ratingView show];
}

#pragma mark - Challenges Availability

+ (void)updateAvailableGetGemsChallenges:(NSArray*)challenges
{
    [[NSUserDefaults standardUserDefaults] setObject:challenges forKey:AvailableChallengesKey];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AvailableChallengesWereSetKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray*)availableGetGemsChallenges
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:AvailableChallengesKey];
}

+ (BOOL)challengeAvailable:(GetGemsChallengeType)type
{
    if(type == GetGemsChallengeInviteAFriendViaWhatsapp)
        return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"Whatsapp://"]];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:AvailableChallengesWereSetKey]) return YES;
    
    NSArray *availlableChallenges = [GetGemsChallenges availableGetGemsChallenges];
    
    NSString *lookedType = [self challengeString:type];
    if (!lookedType) return NO;
    
    for(NSDictionary *dic in availlableChallenges) {
        if([dic[@"txType"] isEqualToString:lookedType])
            return YES;
    }
    return NO;
}

+ (DigitalTokenAmount)amountForChallenge:(GetGemsChallengeType)type
{
    NSString *lookedType = [self challengeString:type];
    if (!lookedType) return 0;
    
    NSArray *availlableChallenges = [GetGemsChallenges availableGetGemsChallenges];
    for(NSDictionary *dic in availlableChallenges) {
        if([dic[@"txType"] isEqualToString:lookedType])
        {
            return [dic[@"amount"] longLongValue];
        }
    }
    return 0;
}

+ (BOOL)hideChallengeAfterCompletion:(GetGemsChallengeType)type
{
    return type == GetGemsChallengeFollowOnFacebook ||
    type == GetGemsChallengeFollowOnTwitter ||
    type == GetGemsChallengeFacebookLogin ||
    type == GetGemsChallengeAppRating;
}

#pragma mark - private
+ (NSString*)challengeString:(GetGemsChallengeType)type
{
    NSString *lookedType;
    switch (type) {
        case GetGemsChallengeFollowOnFacebook:
            lookedType = GemsTransactionFacebookLikeStr;
            break;
        case GetGemsChallengeFollowOnTwitter:
            lookedType = GemsTransactionTwitterLikeStr;
            break;
        case GetGemsChallengeFacebookLogin:
            lookedType = GemsTransactionFacebookLoginStr;
            break;
        case GetGemsChallengeDailyGiveraway:
            lookedType = GemsTransactionFaucetBonusStr;
            break;
        case GetGemsChallengeAppRating:
            lookedType = GemsTransactionRateBonusStr;
            break;
        case GetGemsChallengeAirDrop:
            lookedType = GemsTransactionAirdropStr;
            break;
        default:
            lookedType = nil;
            break;
    }
    
    return lookedType;
}


@end
