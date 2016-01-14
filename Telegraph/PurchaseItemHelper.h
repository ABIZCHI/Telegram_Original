//
//  PurchaseItemHelper.h
//  GetGems
//
//  Created by alon muroch on 6/30/15.
//
//

#import <Foundation/Foundation.h>
#import "FeaturedCell.h"

@interface PurchaseItemHelper : NSObject

+ (void)purchaseItem:(StoreItemData*)itemData completion:(void(^)(bool result, NSString *error))completion;

@end
