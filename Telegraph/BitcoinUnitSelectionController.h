//
//  BitcoinUnitSelectionController.h
//  GetGems
//
//  Created by alon muroch on 6/17/15.
//
//

#import "TGCollectionMenuController.h"

@interface BitcoinUnitSelectionController : TGCollectionMenuController

@property (nonatomic, copy) void (^completionBlock)();

@end
