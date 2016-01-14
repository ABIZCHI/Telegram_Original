//
//  GetGemsCell.h
//  GetGems
//
//  Created by alon muroch on 6/22/15.
//
//

#import "FeaturedCell.h"
#import "AppStoreCellData.h"
#import "GemsStoreCommons.h"

//Currencies
#import <GemsCurrencyManager.h>

@interface GetGemsCellData : AppStoreCellData <NSCoding>

@property (nonatomic, strong) NSString *iconURL, *bannerURL;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *descr;
@property (nonatomic, strong) NSNumber *reward;
@property (nonatomic, strong) Currency *currency;
@property (nonatomic, assign) GetGemsChallengeType type;

@property (nonatomic, assign) BOOL completed;
@property (nonatomic, assign) BOOL didAnimateCompletion;

@end

@interface GetGemsCell : FeaturedCell

@end
