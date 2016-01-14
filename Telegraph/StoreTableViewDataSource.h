//
//  AppStoreTableViewDataSource.h
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import <Foundation/Foundation.h>
#import "AppStoreCellBase.h"
#import "AppStoreHeaderFooterViewBase.h"
#import "BannersTableHeaderView.h"
#import "GemsStoreCommons.h"
#import "GemsTransactionsCommons.h"

typedef enum
{
    StoreGetGemsSection = 0,
    StoreCouponsSection = 1,
}StoreTableViewDataSourceSections;

@interface StoreTableViewDataSource : NSObject <UITableViewDataSource>

@property(atomic, strong) NSArray *banners, *getgemsTasks, *coupons;

@property(nonatomic, strong) id<AppStoreCellDelegate> delegate;

- (void)loadStoreDatafromDefaults;
- (void)refreshDataFromServerWithCompletion:(void(^)(NSString *error))completion;
- (void)bindBannersView:(BannersTableHeaderView*)v;
- (void)updateStoredGetGemsChallengesByRemovingChallengeOfType:(GetGemsChallengeType)type;

+ (void)removeAlCachedDStoreItems;

@end
