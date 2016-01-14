//
//  GemsStoreCommons.h
//  GetGems
//
//  Created by alon muroch on 6/28/15.
//
//

#ifndef GetGems_GemsStoreCommons_h
#define GetGems_GemsStoreCommons_h

typedef enum {
    GetGemsChallengeFollowOnFacebook = 0,
    GetGemsChallengeFollowOnTwitter,
    GetGemsChallengeFacebookLogin,
    GetGemsChallengeFacebookShareApp,
    GetGemsChallengeInviteAFriendViaFB,
    GetGemsChallengeInviteAFriendViaTwitter,
    GetGemsChallengeInviteAFriendViaWhatsapp,
    GetGemsChallengeInviteAFriendViaSMS,
    GetGemsChallengeInviteAFriendViaTelegram,
    GetGemsChallengeInviteAFriendViaMail,
    GetGemsChallengeDailyGiveraway,
    GetGemsChallengeAppRating,
    GetGemsChallengeAirDrop,
}GetGemsChallengeType;

static const NSString *GemsStoreProductTypeCoupons = @"PRODUCT_TYPE_COUPONS";

#endif
