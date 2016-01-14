//
//  PurchaseItemHelper.m
//  GetGems
//
//  Created by alon muroch on 6/30/15.
//
//

#import "PurchaseItemHelper.h"

#import "TGGemsWallet.h"
#import "GemsAnalytics.h"
#import "PaymentRequestsContainer+TG.h"

//GemsCore
#import <PaymentRequest.h>

@implementation PurchaseItemHelper

+ (void)purchaseItem:(StoreItemData*)itemData completion:(void(^)(bool result, NSString *error))completion
{
    PaymentRequestsContainer *container = [PaymentRequestsContainer Factory_newPurchasePayment];
    
    PaymentRequest *pr = [[PaymentRequest alloc] init];
    container.currency = _G;
    
    PurchaseStoreItemInfo *d = [PurchaseStoreItemInfo new];
    d.productId = [itemData.itemID intValue];
    d.price = [itemData.price longLongValue];
    d.itemName = itemData.title;
    
    [pr Store_setStoreItemInfo:d];
    [container.paymentRequests addObject:pr];
   
    [PurchaseItemHelper trackPurchaseRequest:itemData.itemType name:itemData.title];
    [WALLET sendWithPaymentRequests:container authenticate:YES completion:^(bool result, NSString *error) {
        if(completion)
            completion(result, error);
        
        [PurchaseItemHelper trackPurchaseResult:error type:itemData.itemType name:itemData.title];
    }];
}

#pragma mark - analytics

+ (void)trackPurchaseRequest:(StoreItemType)type name:(NSString*)name
{
    NSString *typeStr;
    if(type == StoreItemCoupon)
        typeStr = @"gift card";
    
    [GemsAnalytics track:AnalyticsPurchaseRequest args:@{@"type" : typeStr,
                                                         @"name" : name}];
}

+ (void)trackPurchaseResult:(NSString*)errorStr type:(StoreItemType)type name:(NSString*)name
{
    NSString *typeStr;
    if(type == StoreItemCoupon)
        typeStr = @"gift card";
    
    if(errorStr)
        [GemsAnalytics track:AnalyticsPurchaseError args:@{@"type" : typeStr,
                                                           @"name" : name,
                                                           @"error": errorStr}];
    else
        [GemsAnalytics track:AnalyticsPurchaseSuccess args:@{@"type" : typeStr,
                                                         @"name" : name}];
}

@end
