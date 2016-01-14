//
//  Transaction.h
//  GetGems
//
//  Created by alon muroch on 6/10/15.
//
//

#import <Foundation/Foundation.h>
#import <BRTransaction.h>

#import "FeaturedCell.h"

// Currencies
#import <GemsCurrencyManager.h>

typedef enum {
    TxSend              = 0,      // "SEND"
    TxReceive,                    // "RECEIVE"
    TxDeposit,                    // "DEPOSIT"
    TxWithdrawl,                  // "WITHDRAW"
    TxRegistrationBonus,          // "REGBONUS"
    TxInvBonus,                   // "INVBONUS"
    TxMigrate,                    // "MIGRATE"
    TxAirDrop,                    // "AIRDROP"
    TxFbLike,                     // "Facebook Like"
    TxFbLogin,                    // "Facebook Login"
    TxTwitterLike,                // "Twtter Like"
    TxFaucetBonus,                // "Faucet Bonus"
    TxPurchase,                   // "purchase"
    TxAppRating,                  // "app rating"
    TxTypeKnown
}TransactionType;

@interface NSString (Transaction) <NSCoding>

- (Currency*)txIdToCurrecy;

@end

@interface Transaction : NSObject

@property(nonatomic, strong) NSString *txId;
@property(nonatomic, assign) TransactionType type;
@property(nonatomic, strong) Currency *currency;
@property(nonatomic, assign) DigitalTokenAmount amount;
@property(nonatomic, strong) NSDictionary *source;
@property(nonatomic, strong) NSDictionary *destination;
@property(nonatomic, strong) NSDate *timestamp;

@property (nonatomic, strong) StoreItemData *storeItem;

+ (Transaction*)transactionFromDictionary:(NSDictionary*)data;
+ (Transaction*)transactionFromBRTransactionObject:(BRTransaction*)tx;

@end
