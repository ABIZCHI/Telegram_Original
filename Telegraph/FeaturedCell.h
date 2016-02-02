//
//  FeaturedCell.h
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import <UIKit/UIKit.h>
#import "AppStoreCellBase.h"


#import <PTEHorizontalTableView/PTEHorizontalTableView.h>

// Currencies
#import <GemsCurrencyManager/GemsCurrencyManager.h>

typedef enum {
    StoreItemCoupon = 0,
    StoreItemSticker
}StoreItemType;

@interface StoreItemData : AppStoreCellData <NSCoding>

@property (nonatomic, strong) NSString *iconURL, *cardURL, *bannerURL;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *categoryStr;
@property (nonatomic, strong) NSString *descr;
@property (nonatomic, strong) NSString *tos;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) Currency *currency;
@property (nonatomic, assign) StoreItemType itemType;
@property (nonatomic, assign) NSString *itemID;
@property (nonatomic, assign) NSString *redeemCode;

@end

@interface FeaturedCell : AppStoreCellBase <PTETableViewDelegate>

@property(nonatomic, strong) id<AppStoreCellDelegate> delegate;


@property(nonatomic, strong) PTEHorizontalTableView *tblViewWrapper;
@property(nonatomic, strong) UITableView *tblView;

// cell properties
@property(nonatomic, strong) UIColor *featureCellTitleColor, *featureCellDetailsColor;

@end
