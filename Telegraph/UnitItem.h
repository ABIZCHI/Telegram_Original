//
//  UnitItem.h
//  GetGems
//
//  Created by alon muroch on 6/17/15.
//
//

#import "TGCheckCollectionItem.h"

// Currencies
#import <GemsCurrencyManager/GemsCurrencyManager.h>

@interface UnitItem : TGCheckCollectionItem

@property(nonatomic, assign) BitcoinUnit denomination;

- (instancetype)initWithUnitName:(NSString*)name action:(SEL)action;
- (void)setIsChecked:(bool)isChecked;

@end
