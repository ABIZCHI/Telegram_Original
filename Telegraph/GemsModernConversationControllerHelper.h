//
//  GemsModernConversationControllerHelper.h
//  GetGems
//
//  Created by alon muroch on 4/7/15.
//
//

#import <Foundation/Foundation.h>
#import "GemsModernConversationController.h"
#import "GroupPinCodeView.h"
#import "GroupPayeesCollectionView.h"
#import "SinglePinCodeView.h"

// GemsCore
#import <GemsCore/PaymentRequestsContainer.h>

static BOOL PrivateConversation(int64_t cid) {  return cid > 0; }
static BOOL SecretConversation(int64_t cid) { return cid <= INT_MIN; }
static BOOL GroupConversation(int64_t cid) { return cid > INT_MIN && cid <= 0; }


@interface GemsModernConversationControllerHelper : NSObject
- (instancetype)initWithConversationID:(int64_t)conversationID conversationController:(GemsModernConversationController*)controller;

- (void)fetchConversationDataFromServerCompletion:(void(^)(NSArray *gemsUserIdsByTgId, NSString *error))completion;
- (NSArray *)fetchStoredConversationData;
- (void)fetchReferralURLCompletion:(void(^)(NSURL *referralURL, NSString *error))completion;

- (void)sendTippingInGroupPaymentRequest:(PaymentRequestsContainer*)prContainer referralURL:(NSURL*)referralURL;
- (void)sendPersonalPaymentRequest:(PaymentRequestsContainer*)prContainer referralURL:(NSURL*)referralURL;
- (void)sendGroupPaymentRequests:(PaymentRequestsContainer*)prContainer referralURL:(NSURL*)referralURL;

@end
