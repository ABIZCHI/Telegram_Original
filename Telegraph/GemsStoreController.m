//
//  GemsAppStoreController.m
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "GemsStoreController.h"
#import "AppStoreCellBase.h"
#import "AppStoreHeaderFooterViewBase.h"
#import "FeaturedHeader.h"
#import "FeaturedCell.h"
#import "BannersTableHeaderView.h"
#import "FeatureController.h"
#import "SquareImageCell.h"
#import "FeaturedAllController.h"
#import "GetGemsCell.h"
#import "GetGemsChallenges.h"
#import "SocialSharerHelper.h"
#import "GemsStoreCommons.h"
#import "TGAppDelegate.h"

#import "GemsAlertCenter.h"
#import "GemsAlert.h"
#import "GemsAirdropAlert.h"

#import <SDWebImage/UIImageView+WebCache.h>

// Networking
#import <GemsNetworking/GemsNetworking.h>

// GemsCore
#import <GemsCore/GemsCD.h>
#import <GemsCore/GemsAnalytics.h>

// GemsUI
#import <GemsUI/UserNotifications.h>

@interface GemsStoreController () <UITableViewDelegate, AppStoreCellDelegate, UINavigationControllerDelegate>
{
    BannersTableHeaderView *_tblHeaderView;
    
    NSMutableArray *_cellsFotUpdate;
    
    SocialSharerHelper *_sharerHelper;
}

@end

@implementation GemsStoreController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self setTitleText:GemsLocalized(@"GemsStore")];
    
    _tblDataSource = [[StoreTableViewDataSource alloc] init];
    _tblDataSource.delegate = self;
    _tblView.dataSource = _tblDataSource;
    [_tblView setShowsHorizontalScrollIndicator:NO];
    [_tblView setShowsVerticalScrollIndicator:NO];
    [_tblView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self setupTableHeader];
    
    _cellsFotUpdate = [[NSMutableArray alloc] init];
    
    [_tblDataSource loadStoreDatafromDefaults];
    [_tblDataSource bindBannersView:_tblHeaderView];
    [_tblView reloadData];
    
    [_tblDataSource refreshDataFromServerWithCompletion:^(NSString *error) {
        if(error) {
            [UserNotifications showUserMessage:error];
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tblDataSource bindBannersView:_tblHeaderView];
            [_tblView reloadData];
        });
    }];
    
    _sharerHelper = [[SocialSharerHelper alloc] init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicaitonDidBecomeActive)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _tblHeaderView.bounds = CGRectMake(0, 0, _tblView.frame.size.width , [BannersTableHeaderView height]);
    [_tblView setTableHeaderView:_tblHeaderView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set outself as the navigation controller's delegate so we're asked for a transitioning object
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop being the navigation controller's delegate
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (void)setupTableHeader
{
    _tblHeaderView = [[BannersTableHeaderView alloc] init];
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppStoreCellBase *cell = (AppStoreCellBase*)[_tblDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    return [[cell class] cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (CGFloat)tableView:(UITableView*)tableView
heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    FeaturedHeader *h = [[FeaturedHeader alloc] init];
    if(section == StoreGetGemsSection) {
        h.lblTitle.text = @"GET GEMS";
//        h.seeMoreBlock = ^() {
//            [self pushFeaturedAllControllerWithData:_tblDataSource.getgemsTasks andTitle:@"GET GEMS"];
//        };
        h.seeMoreBlock = NilCompletionBlock;
        h.seperatorView.hidden = YES;
    }
    
    if(section == StoreCouponsSection) {
        h.lblTitle.text = @"REDEEM GIFTS";
        h.seeMoreBlock = ^() {
            [self pushFeaturedAllControllerWithData:_tblDataSource.coupons andTitle:@"REDEEM GIFTS"];
        };
    }
    
    return h;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UIView * headerview = (UIView *)view;
    headerview.backgroundColor = [UIColor clearColor];
}

- (void)pushFeaturedAllControllerWithData:(NSArray*)arr andTitle:(NSString*)title
{
    FeaturedAllController *v = [[FeaturedAllController alloc] initWithNibName:@"FeaturedAllController" bundle:nil];
    [v setupWithData:arr];
    [v setTitleText:title];
    pushController(v, YES);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = [self calculateTableViewRealContentOffset:scrollView];
    
    [_tblHeaderView freezeMovmentForOffset:offset];
}

- (CGFloat)calculateTableViewRealContentOffset:(UIScrollView*)scrl
{
    static CGFloat initialScrlOffset;
    if(!initialScrlOffset)
        initialScrlOffset = scrl.contentOffset.y;
    return -(scrl.contentOffset.y - initialScrlOffset);;
}

#pragma mark - AppStoreCellDelegate

- (void)didSelectCell:(AppStoreCellBase*)cell inContainingCell:(AppStoreCellBase*)containingCell data:(AppStoreCellData*)data
{
    if([cell isMemberOfClass:[SquareImageCell class]] && containingCell.indexPath.section == StoreCouponsSection)
    {
        FeatureController *v = [[FeatureController alloc] initWithNibName:@"FeatureController" bundle:nil];
        [v setupWithData:data];
        pushController(v, YES);
    }
    
    if([cell isMemberOfClass:[SquareImageCell class]] && containingCell.indexPath.section == StoreGetGemsSection)
    {
        GetGemsCellData *data = (GetGemsCellData*)((SquareImageCell*)cell).data;
        
        switch (data.type) {
            case GetGemsChallengeFollowOnFacebook:
            {
                [GetGemsChallenges launchFollowOnFacebookChallenge];
                
                [self postIssueBonusRequestForBonusType:GemsTransactionFacebookLikeStr completion:^(NSString *error) {
                   if(error)
                   {
                       [UserNotifications showUserMessage:error];
                       return ;
                   }
                    
                    [self trackEarnGemsBonus:@"facebook like"];
                    
                    [_tblDataSource updateStoredGetGemsChallengesByRemovingChallengeOfType:GetGemsChallengeFollowOnFacebook];
                    ((GetGemsCellData*)data).completed = YES;
                    [_cellsFotUpdate addObject:@[cell, containingCell]];
                }];
            }
                break;
            case GetGemsChallengeFollowOnTwitter:
            {
                [GetGemsChallenges launchFollowOnTwitterChallenge];
                
                [self postIssueBonusRequestForBonusType:GemsTransactionTwitterLikeStr completion:^(NSString *error) {
                    if(error)
                    {
                        [UserNotifications showUserMessage:error];
                        return ;
                    }
                    
                    [self trackEarnGemsBonus:@"twitter follow"];
                    
                    [_tblDataSource updateStoredGetGemsChallengesByRemovingChallengeOfType:GetGemsChallengeFollowOnTwitter];
                    ((GetGemsCellData*)data).completed = YES;
                    [_cellsFotUpdate addObject:@[cell, containingCell]];
                }];
            }
                break;
            case GetGemsChallengeFacebookLogin:
            {
                [GetGemsChallenges loginToFacebookAndGetUserDataWithCompletion:^(NSString *error) {
                    if(error)
                    {
                        [UserNotifications showUserMessage:error];
                    }
                    else {
                        [self postIssueBonusRequestForBonusType:GemsTransactionFacebookLoginStr completion:^(NSString *error) {
                            if(error)
                            {
                                [UserNotifications showUserMessage:error];
                                return ;
                            }
                            [self trackEarnGemsBonus:@"facebook login"];
                            
                            ((GetGemsCellData*)data).completed = YES;
                            [_cellsFotUpdate addObject:@[cell, containingCell]];
                            [self updateCellsForUpdate];
                            
                            [[GemsAlertCenter sharedInstance] addAlertsToDefaults:@[[GemsAlert gemsAlertFromDictionary:@{@"type" : GemsTransactionFacebookLikeStr,
                                                                                                                         @"alertId" : [[NSUUID UUID] UUIDString],
                                                                                                                         @"wasRead" : @NO}]]];
                            [[GemsAlertCenter sharedInstance] executeAllPendingAlerts];
                        }];
                    }
                }];
            }
                break;
            case GetGemsChallengeFacebookShareApp:
                [_sharerHelper inviteViaFB:self];
                [self trackInviteViaSocial:@"facebook"];
                break;
            case GetGemsChallengeInviteAFriendViaFB:
            {
                FBSDKGameRequestDialogCallback *callback = [FBSDKGameRequestDialogCallback new];
                callback.didCompleteWithResults = ^(NSDictionary *results)
                {
                    
                };
                
                callback.didFailWithError = ^(NSString *error)
                {
                    [UserNotifications showUserMessage:error];
                };
                
                [GetGemsChallenges shareAppOnFacebookWithCallback:callback];
            }
                
                break;
            case GetGemsChallengeInviteAFriendViaTwitter:
                [_sharerHelper inviteViaTwitter:self];
                [self trackInviteViaSocial:@"twitter"];
                break;
            case GetGemsChallengeInviteAFriendViaWhatsapp:
                [_sharerHelper inviteViaWhatsApp];
                [self trackInviteViaSocial:@"whatsapp"];
                break;
            case GetGemsChallengeInviteAFriendViaSMS:
                [_sharerHelper inviteViaSms];
                [self trackInviteViaSocial:@"sms"];
                break;
            case GetGemsChallengeInviteAFriendViaTelegram:
                [_sharerHelper inviteViaTelegram];
                [self trackInviteViaSocial:@"telegram"];
                break;
            case GetGemsChallengeInviteAFriendViaMail:
                [_sharerHelper inviteViaEmail:self];
                [self trackInviteViaSocial:@"email"];
                break;
            case GetGemsChallengeAppRating:
            {
                [GetGemsChallenges rateAppWithDidRateCompletion:^(bool didRate, int rating) {
                    if(didRate)
                        [self postIssueBonusRequestForBonusType:GemsTransactionRateBonusStr completion:^(NSString *error) {
                            if(error)
                            {
                                [UserNotifications showUserMessage:error];
                                return ;
                            }
                                                    
                            ((GetGemsCellData*)data).completed = YES;
                            [_cellsFotUpdate addObject:@[cell, containingCell]];
                            [self updateCellsForUpdate];
                        }];
                }];

                [GemsAnalytics track:AnalyticsUserAppRatePopup args:@{@"origin" : @"store"}];
            }
                break;
            case GetGemsChallengeDailyGiveraway:
            {
                [self postIssueBonusRequestForBonusType:GemsTransactionFaucetBonusStr completion:^(NSString *error) {
                    if(error)
                    {
                        [UserNotifications showUserMessage:error];
                        return ;
                    }
                    
                    [self trackEarnGemsBonus:@"daily"];
                    
                    ((GetGemsCellData*)data).completed = YES;
                    [_cellsFotUpdate addObject:@[cell, containingCell]];
                    [self updateCellsForUpdate];
                }];
            }
                break;
            case GetGemsChallengeAirDrop:
            {
                if([GetGemsChallenges challengeAvailable:GetGemsChallengeAirDrop]) {
                    [self postIssueBonusRequestForBonusType:GemsTransactionAirdropStr completion:^(NSString *error) {
                        if(error)
                        {
                            [UserNotifications showUserMessage:error];
                            return ;
                        }
                        
                        [self trackEarnGemsBonus:@"airdrop"];
                        
                        ((GetGemsCellData*)data).completed = YES;
                        [_cellsFotUpdate addObject:@[cell, containingCell]];
                        [self updateCellsForUpdate];
                    }];
                }
                else {
                    GemsAirdropAlert *alert = [GemsAirdropAlert new];
                    [[GemsAlertCenter sharedInstance] addAlertsToDefaults:@[alert]];
                    [[GemsAlertCenter sharedInstance] executeAllPendingAlerts];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)postIssueBonusRequestForBonusType:(NSString*)type completion:(void(^)(NSString *error))completion
{
    [API issueBonus:type respond:^(GemsNetworkRespond *respond) {
        if([respond hasError]) {
            if(completion)
                completion(respond.error.localizedError);
        }
        else {
            if(completion)
                completion(nil);
        }
    }];
}

- (void)updateCellsForUpdate
{
    // update cells
    for(NSArray *arr in _cellsFotUpdate) {
        AppStoreCellBase *cell = arr[0];
        AppStoreCellBase *containingCell = arr[1];
        
        if(containingCell.indexPath.section == 0)
        {
            if(cell.indexPath && ((FeaturedCell*)containingCell).tblView)
                [((FeaturedCell*)containingCell).tblView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    _cellsFotUpdate = [[NSMutableArray alloc] init];
}

#pragma mark - NSNotifications

- (void)applicaitonDidBecomeActive
{
    [self updateCellsForUpdate];
}

#pragma mark -
+ (void)logoutCleanup
{
    NSLog(@"Cleaned up store NSDefaults");
    [StoreTableViewDataSource removeAlCachedDStoreItems];
}

#pragma mark - analytics

- (void)trackInviteViaSocial:(NSString*)platform
{
    [GemsAnalytics track:AnalyticsShareViaSocial args:@{@"platform": platform,
                                                        @"origin" : @"shop"}];
}

- (void)trackEarnGemsBonus:(NSString*)bonus
{
    [GemsAnalytics track:AnalyticsEarnGemsBonus args:@{@"type": bonus}];
}

#pragma mark - screen orientation

- (NSUInteger) supportedInterfaceOrientations
{
    if(IS_IPAD)
        return UIInterfaceOrientationMaskAll;
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
