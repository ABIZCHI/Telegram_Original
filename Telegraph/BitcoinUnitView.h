//
//  BitcionUnitCell.h
//  GetGems
//
//  Created by alon muroch on 6/17/15.
//
//

#import "TGCheckCollectionItemView.h"

// Currencies
#import <GemsCurrencyManager/GemsCurrencyManager.h>

@interface BitcoinUnitView : TGCheckCollectionItemView

@property(nonatomic, strong) UILabel *lblName;
@property(nonatomic, assign) BitcoinUnit denomination;

@end
