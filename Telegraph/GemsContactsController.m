//
//  GemsContactsController.m
//  GetGems
//
//  Created by alon muroch on 3/17/15.
//
//

#import "GemsContactsController.h"
#import "ExtensionConst.h"
#import "TGUser+TGUser_Coding.h"

// GemsCore
#import <GemsCore/GemsCD.h>
#import <GemsCore/NSURL+GemsReferrals.h>
#import <GemsCore/GemsStringUtils.h>
#import <GemsCore/GemsAnalytics.h>

@implementation GemsContactsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSURL urlWithMyUniqueReferralLinkCompletion:^(NSURL *url, NSError *error) {
        self.referralURL = url.absoluteString;
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(_simulteInviteFriendsPressOnViewDidAppear)
    {
        [self pushInviteContactsWithShouldSimulateSelectAll:YES];
        _simulteInviteFriendsPressOnViewDidAppear = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}

- (void)updateSelectionInterface
{
    [super updateSelectionInterface];
    
    UIView *allignmentContainer = [self.inviteContainer viewWithTag:99];
    UILabel *inviteLabel = (UILabel*)[allignmentContainer viewWithTag:100];
    UILabel *countLabel = (UILabel *)[allignmentContainer viewWithTag:102];
    
    GemsAmount *ga = [[GemsAmount alloc] initWithAmount:1 currency:_G unit:Gem];
    float selectedCnt = [countLabel.text floatValue];
    float oneGemUSDValue = [[ga toFiat:[self getFiatCode]] floatValue];
    float totReward = oneGemUSDValue * (float)kGemsRewardUserInvite * selectedCnt;
    
    inviteLabel.text = [NSString stringWithFormat:@"%@ (%@ %@%@)", GemsLocalized(@"Contacts.InviteToGetGems"), GemsLocalized(@"GemsEarn"), [GemsStringUtils fiatSymbolFromFiatCode:[self getFiatCode]], formatDoubleToStringWithDecimalPrecision(totReward, 2)];
}

#pragma mark - currency coversion
-(NSString*)getFiatCode
{
    CDGemsSystem *s = [CDGemsSystem MR_findFirst];
    return [s.currencySymbol uppercaseString];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (indexPath.section == 1)
    {
        TGUser *user = [self.globalSearchResults objectAtIndex:indexPath.row];
        [self trackUnsolicitedMsg:user];
    }
}

#pragma mark - analytics

- (void)trackUnsolicitedMsg:(TGUser*)user
{
    if(user.userName)
        [GemsAnalytics track:AnalyticsUnsolicitedMsg args:@{@"username": user.userName}];
}

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result
{
    [super actorCompleted:resultCode path:path result:result];
    
    if ([path isEqualToString:@"/tg/contactlist/(contacts)"])
    {
        if (resultCode == 0)
        {
            NSDictionary *resultDict = ((SGraphObjectNode *)result).object;
            NSArray *contacts = [resultDict objectForKey:@"contacts"];
            
            /**
              * We store the contacts for later use in the kb extension
              * so to not load the whole telegram core
             */
            NSMutableArray *toStore = [NSMutableArray new];
            for (TGUser *u in contacts) {
                [toStore addObject:[u tgContact]];
            }
            NSData *dic = [NSKeyedArchiver archivedDataWithRootObject:toStore];
            NSUserDefaults *def = [[NSUserDefaults alloc] initWithSuiteName:appGroupsSuite];
            [def setObject:dic forKey:cachedTGUsersKey];
        }
    }
}

@end
