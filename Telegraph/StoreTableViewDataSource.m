//
//  AppStoreTableViewDataSource.m
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "StoreTableViewDataSource.h"
#import "FeaturedCell.h"
#import "GetGemsCell.h"
#import "TGCommon.h"
#import "TGAppearance.h"
#import "GetGemsChallenges.h"

// GemsCore
#import <GemsCD.h>
#import <GemsCore/Macros.h>
#import <GemsCore/GemsCommons.h>

// networking
#import <GemsNetworking.h>

#define STORE_AVAILBLE_CHALLENGES_KEY @"STORE_AVAILBLE_CHALLENGES_KEY"
#define STORE_PRODUCTS_KEY @"STORE_PRODUCTS_KEY"

@interface StoreTableViewDataSource()
{
    dispatch_queue_t _dataFetchQueue;
}


@end

@implementation StoreTableViewDataSource

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _dataFetchQueue = dispatch_queue_create("dataFetchQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - fetching data

+ (void)removeAlCachedDStoreItems
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORE_PRODUCTS_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORE_AVAILBLE_CHALLENGES_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadStoreDatafromDefaults
{
    NSData *d;
    _banners = [self storeBanners];
    
    _coupons = NSDefaultOrEmptyArray(STORE_PRODUCTS_KEY);
    
    _getgemsTasks = NSDefaultOrEmptyArray(STORE_AVAILBLE_CHALLENGES_KEY);
    if(_getgemsTasks.count == 0) // first time loading
        _getgemsTasks = [self inviteChallenges];
}

- (void)refreshDataFromServerWithCompletion:(void(^)(NSString *error))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSString *_error;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        [self fetchGetGemsTasksDataWithCompletion:^(NSArray *data, NSString *error) {
            if(!_error)
                _error = error;
            
            if(data.count == 0) {
                dispatch_semaphore_signal(sema);
                return ;
            }
            
            self.getgemsTasks = data;
            _banners = [self storeBanners];

            dispatch_semaphore_signal(sema);
        }];
        
        [self fetchCouponsDataWithCompletion:^(NSArray *data, NSString *error) {
            if(!_error)
                _error = error;
            
            if(data.count ==0) {
                dispatch_semaphore_signal(sema);
                return ;
            }

            self.coupons = data;
            
            dispatch_semaphore_signal(sema);
        }];
        
        dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)));
        dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)));
        
        NSData *d = [NSKeyedArchiver archivedDataWithRootObject:_getgemsTasks];
        [[NSUserDefaults standardUserDefaults] setObject:d forKey:STORE_AVAILBLE_CHALLENGES_KEY];
        d = [NSKeyedArchiver archivedDataWithRootObject:_coupons];
        [[NSUserDefaults standardUserDefaults] setObject:d forKey:STORE_PRODUCTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if(completion)
            completion(_error);
    });
}

- (void)fetchBannerDataWithCompletion:(void(^)(NSArray *data, NSString *error))completion
{
    if(completion)
        completion([self storeBanners], nil);
}

- (void)fetchGetGemsTasksDataWithCompletion:(void(^)(NSArray *data, NSString *error))completion
{
    if(completion) {
        [API getAvailableBonuses:^(GemsNetworkRespond *respond) {
            if([respond hasError])
            {
                if(completion)
                    completion(nil, respond.error.localizedError);
                return ;
            }
            
            [GetGemsChallenges updateAvailableGetGemsChallenges:respond.rawResponse[@"availableBonuses"]];
            NSMutableArray *ret = [[NSMutableArray alloc] init];
            
            // faucet
            BOOL didComplete = ![GetGemsChallenges challengeAvailable:GetGemsChallengeDailyGiveraway];
            GetGemsCellData *faucet = [GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeDailyGiveraway),
                                                                            @"iconUrl": @"http://i.imgur.com/kfginN8.png",
                                                                            @"title": @"Daily Giveaway",
                                                                            @"descr" : @"Want some Gems for free ? Click here",
                                                                            @"reward": @(kGemsRewardDailyFaucet*GEM), @"asset" : @"GEMS",
                                                                            @"completed" : @(didComplete),
                                                                            @"didAnimateCompletion" : @(didComplete)}];
            [ret addObject:faucet];
            
            // rate us - cancelled because of app store rejection
//            if([GetGemsChallenges challengeAvailable:GetGemsChallengeAppRating])
//                [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeAppRating),
//                                                                     @"iconUrl": @"http://i.imgur.com/lpM0MMc.png",
//                                                                     @"title": @"Rate GetGems",
//                                                                     @"descr" : @"",
//                                                                     @"reward": @(kGemsRewardAppRating*GEM), @"asset" : @"GEMS"}]];
            
            
            // airdrop
            if([GetGemsChallenges challengeAvailable:GetGemsChallengeAirDrop]) {
                GemsAmount *amount = [[GemsAmount alloc] initWithAmount:[GetGemsChallenges amountForChallenge:GetGemsChallengeAirDrop] currency:_G unit:Gillo];
                [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeAirDrop),
                                                                     @"iconUrl": @"http://i.imgur.com/DrfEIEj.png",
                                                                     @"title": @"AirDrop",
                                                                     @"descr" : @"Want some Gems for free ? Click here",
                                                                     @"reward": [amount NSNumber], @"asset" : @"GEMS",
                                                                     @"completed" : @(NO),
                                                                     @"didAnimateCompletion" : @(NO)}]];
            }
            else {
                [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeAirDrop),
                                                                     @"iconUrl": @"http://i.imgur.com/DrfEIEj.png",
                                                                     @"title": @"AirDrop",
                                                                     @"descr" : @"Want some Gems for free ? Click here",
                                                                     @"completed" : @(NO),
                                                                     @"didAnimateCompletion" : @(NO)}]];
            }
            
            // fb login
            if([GetGemsChallenges challengeAvailable:GetGemsChallengeFacebookLogin])
                [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeFacebookLogin),
                                                                     @"iconUrl": @"http://i.imgur.com/sT0pssk.png",
                                                                     @"title": @"Login to facebook",
                                                                     @"descr" : @"Login to facebook with GetGems",
                                                                     @"reward": @(kGemsRewardFbLogin*GEM), @"asset" : @"GEMS",}]];
            
            // twitter like
            if([GetGemsChallenges challengeAvailable:GetGemsChallengeFollowOnTwitter])
                [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeFollowOnTwitter),
                                                                     @"iconUrl": @"http://i.imgur.com/raXkLlI.png",
                                                                     @"title": @"Follow us on Twitter",
                                                                     @"descr" : @"Follow us on Twitter and get 25 Gems !",
                                                                     @"reward": @(kGemsRewardTwitterFollow*GEM), @"asset" : @"GEMS"}]];
            
            
            ret = [[NSMutableArray alloc] initWithArray:[ret arrayByAddingObjectsFromArray:[self inviteChallenges]]];
            
            // fb share app
            [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeFacebookShareApp),
                                                                 @"iconUrl": @"http://i.imgur.com/qyewT8t.png",
                                                                 @"title": @"Share GetGems on Facebook",
                                                                 @"descr" : @"Share GetGems on Facebook",
                                                                 @"reward": @(25*GEM), @"asset" : @"GEMS"}]];
            
            // twitter share
            [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeInviteAFriendViaTwitter),
                                                                 @"iconUrl": @"http://i.imgur.com/gC2AV2q.png",
                                                                 @"title": @"Invite Friends via Twitter",
                                                                 @"descr" : @"Invite your friends via Twitter and get 25 Gems when they register !",
                                                                 @"reward": @(25*GEM), @"asset" : @"GEMS"}]];
            
            
            if(completion)
                completion(ret, nil);
        }];
    }
}

- (void)fetchCouponsDataWithCompletion:(void(^)(NSArray *data, NSString *error))completion
{
    [API getStoreProductsByType:(NSString*)GemsStoreProductTypeCoupons respond:^(GemsNetworkRespond *respond) {
        if([respond hasError]) {
            if(completion)
                completion(nil, respond.error.localizedError);
            return ;
        }
        
        NSArray *arr = respond.rawResponse[@"products"];
        NSMutableArray *ret = [[NSMutableArray alloc] init];
        for(NSDictionary *dic in arr) {
            NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
            mDic[@"typeName"] = GemsStoreProductTypeCoupons;
            StoreItemData *d = [StoreItemData dataFromDictinary:mDic];
            if(d)
                [ret addObject:d];
        }
        
        if(completion)
            completion(ret, nil);
    }];
}

- (NSArray*)storeBanners
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeInviteAFriendViaFB),
                                                         @"bannerUrl" : @"http://i.imgur.com/I6LbSxb.png",
                                                         @"reward": @(25*GEM),
                                                         @"asset" : @"GEMS"}]];
    if([GetGemsChallenges challengeAvailable:GetGemsChallengeFollowOnFacebook])
        [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeFollowOnFacebook),
                                                             @"bannerUrl" : @"http://i.imgur.com/jj99220.png",
                                                             @"reward": @(25*GEM),
                                                             @"asset" : @"GEMS"}]];
    [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeInviteAFriendViaTwitter),
                                                         @"bannerUrl" : @"http://i.imgur.com/W7HopnR.png",
                                                         @"reward": @(25*GEM),
                                                         @"asset" : @"GEMS"}]];
    if([GetGemsChallenges challengeAvailable:GetGemsChallengeInviteAFriendViaWhatsapp])
        [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeInviteAFriendViaWhatsapp),
                                                             @"bannerUrl" : @"http://i.imgur.com/WNO7kxK.png",
                                                             @"reward": @(25*GEM),
                                                             @"asset" : @"GEMS"}]];
    [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeInviteAFriendViaTelegram),
                                                         @"bannerUrl" : @"http://i.imgur.com/i5Cdkmr.png",
                                                         @"reward": @(25*GEM),
                                                         @"asset" : @"GEMS"}]];
    
    return ret;
}

- (NSArray*)inviteChallenges
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeInviteAFriendViaFB),
                                                         @"iconUrl": @"http://i.imgur.com/NLEtxer.png",
                                                         @"title": @"Invite Friends via Facebook",
                                                         @"descr" : @"Invite your friends via Facebook and get 25 Gems when they register !",
                                                         @"reward": @(25*GEM),
                                                         @"asset" : @"GEMS"}]];
    if([GetGemsChallenges challengeAvailable:GetGemsChallengeInviteAFriendViaWhatsapp])
        [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeInviteAFriendViaWhatsapp),
                                                             @"iconUrl": @"http://i.imgur.com/R2qrUXa.png",
                                                             @"title": @"Invite Friends via Whatsapp",
                                                             @"descr" : @"Invite your friends via Whatsapp and get 25 Gems when they register !",
                                                             @"reward": @(25*GEM),
                                                             @"asset" : @"GEMS"}]];
    [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeInviteAFriendViaSMS),
                                                         @"iconUrl": @"http://i.imgur.com/MckptKb.png",
                                                         @"title": @"Invite Friends via SMS",
                                                         @"descr" : @"Invite your friends via SMS and get 25 Gems when they register !",
                                                         @"reward": @(25*GEM),
                                                         @"asset" : @"GEMS"}]];
    [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeInviteAFriendViaTelegram),
                                                         @"iconUrl": @"http://i.imgur.com/McZZ1BQ.png",
                                                         @"title": @"Invite Friends via Telegram",
                                                         @"descr" : @"Invite your friends via Telegram and get 25 Gems when they register !",
                                                         @"reward": @(25*GEM),
                                                         @"asset" : @"GEMS"}]];
    [ret addObject:[GetGemsCellData dataFromDictinary:@{ @"type" : @(GetGemsChallengeInviteAFriendViaMail),
                                                         @"iconUrl": @"http://i.imgur.com/R16tmDR.png",
                                                         @"title": @"Invite Friends via Email",
                                                         @"descr" : @"Invite your friends via eMail and get 25 Gems when they register !",
                                                         @"reward": @(25*GEM),
                                                         @"asset" : @"GEMS"}]];
    
    return ret;
}

- (void)updateStoredGetGemsChallengesByRemovingChallengeOfType:(GetGemsChallengeType)type
{
    NSInteger idx = NSNotFound;
    for(NSUInteger i = 0 ; i < _getgemsTasks.count ; i++)
    {
        GetGemsCellData *d = _getgemsTasks[i];
        if(d.type == type) {
            idx = i;
            break;
        }
    }
    
    if(idx != NSNotFound)
    {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:_getgemsTasks];
        [arr removeObjectAtIndex:idx];
        _getgemsTasks = arr;
    }
    
    // store in defaults
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:_getgemsTasks];
    [[NSUserDefaults standardUserDefaults] setObject:d forKey:STORE_AVAILBLE_CHALLENGES_KEY];
}

- (void)bindBannersView:(BannersTableHeaderView*)v
{
    v.delegate = _delegate;
    [v bind:_banners];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get Gems
    if(indexPath.section == StoreGetGemsSection)
    {
        FeaturedCell *cell = (FeaturedCell *)[tableView dequeueReusableCellWithIdentifier:[FeaturedCell cellIdentifier]];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FeaturedCell" owner:self options:nil];
            cell = (FeaturedCell *)[nib objectAtIndex:0];
        }
        
        cell.delegate = _delegate;
        cell.indexPath = indexPath;
        
        cell.featureCellTitleColor = [UIColor darkGrayColor];
        cell.featureCellDetailsColor = TGAccentColor();
        
        [cell bindCell:_getgemsTasks];
        
        return cell;
    }
    
    // Redeem Gifts
    if(indexPath.section == StoreCouponsSection)
    {
        FeaturedCell *cell = (FeaturedCell *)[tableView dequeueReusableCellWithIdentifier:[FeaturedCell cellIdentifier]];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FeaturedCell" owner:self options:nil];
            cell = (FeaturedCell *)[nib objectAtIndex:0];
        }
        
        cell.delegate = _delegate;
        cell.indexPath = indexPath;
        
        cell.featureCellTitleColor = [UIColor blackColor];
        cell.featureCellDetailsColor = TGAccentColor();
        
        [cell bindCell:_coupons];        
        
        return cell;
    }

    
    return nil;
}

@end
