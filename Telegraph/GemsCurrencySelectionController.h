//
//  GemsCurrencySelectionController.h
//  GetGems
//
//  Created by alon muroch on 5/12/15.
//
//

#import "TGCollectionMenuController.h"

@interface GemsCurrencySelectionController : TGCollectionMenuController

@property (nonatomic, copy) void (^completionBlock)();

@end
