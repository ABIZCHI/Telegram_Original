//
//  Transaction.m
//  GetGems
//
//  Created by alon muroch on 6/10/15.
//
//

#import "Transaction.h"
#import <NSString+Bitcoin.h>
#import <BRSPVWalletManager.h>
#import <BRTransaction.h>
#import "GemsTransactionsCommons.h"
#import <NSData+Bitcoin.h>

#define TX_REFERENCE_TIME(t) (t - NSTimeIntervalSince1970)

@implementation NSString (Transaction)

- (Currency*)txIdToAsset
{
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([self rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        return _G;
    }
    return _B;
}


@end

@implementation Transaction

+ (Transaction*)transactionFromDictionary:(NSDictionary*)data
{
    Transaction *ret = [[Transaction alloc] init];
    ret.type = [self typeByTxTypeString:[data objectForKey:@"type"]];
    if(ret.type == TxTypeKnown) return nil;
    
    ret.txId = [data objectForKey:@"txtid"];
    if(ret.type == TxPurchase)
        ret.storeItem = [StoreItemData dataFromDictinary:[data objectForKey:@"product"]];
    ret.currency = [self currencyFromSymbol:[data objectForKey:@"asset"]];
    ret.amount = [[data objectForKey:@"amount"] longLongValue];
    ret.source = (NSDictionary*)[data objectForKey:@"source"];
    ret.destination = (NSDictionary*)[data objectForKey:@"destination"];
    {
        NSTimeInterval unix = [[data objectForKey:@"timestamp"] doubleValue];
        ret.timestamp = [NSDate dateWithTimeIntervalSince1970:unix];
        
        if(ret.timestamp == nil)
            return nil;
    }
    
    return ret;
}

+ (Transaction*)transactionFromBRTransactionObject:(BRTransaction*)tx
{
    BRWallet *wallet = [BRSPVWalletManager sharedInstance].wallet;
    
    Transaction *ret = [[Transaction alloc] init];
    ret.currency = _B;
    ret.txId = [NSString hexWithData:tx.txHash.reverse];
    {
        uint64_t amountReceived = [wallet amountReceivedFromTransaction:tx];
        uint64_t amountSent = [wallet amountSentByTransaction:tx];
        
        if(amountSent > 0) {
            ret.type = TxWithdrawl;
            
            uint64_t outputAmount = 0;
            for(NSUInteger i=0 ; i < tx.outputAmounts.count ; i ++)
                outputAmount += [[tx.outputAmounts objectAtIndex:i] int64Value];
            
            ret.amount = outputAmount - amountReceived;
            
            ret.source = @{@"address": ret.txId};
            ret.destination = @{@"address": @"Not Known"}; // for default
            for (NSString *add in tx.outputAddresses) {
                if(![wallet containsAddress:add])
                {
                    ret.destination = @{@"address": add};
                    break;
                }
            }
        }
        else {
            ret.type = TxDeposit; 
            ret.amount = amountReceived;
            
            ret.source = @{@"address": ret.txId};
            ret.destination = @{@"address": @"Not Known"}; // for default
            for (NSString *add in tx.outputAddresses) {
                if([wallet containsAddress:add])
                {
                    ret.destination = @{@"address": add};
                    break;
                }
            }
        }
    }
    
    ret.timestamp = [NSDate dateWithTimeInterval:TX_REFERENCE_TIME(tx.timestamp) sinceDate:[NSDate dateWithTimeIntervalSinceReferenceDate:BITCOIN_NETWORK_REFERECE_TIMESTAMP]];
    if(ret.timestamp == nil)
        return nil;
    
    return ret;
}

+ (TransactionType)typeByTxTypeString:(NSString const *)str
{
    str = [str uppercaseString];
    if([str isEqualToString:GemsTransactionSendStr])
        return TxSend;
    if([str isEqualToString:GemsTransactionReceiveStr])
        return TxReceive;
    if([str isEqualToString:GemsTransactionDepositStr])
        return TxDeposit;
    if([str isEqualToString:GemsTransactionWithdrawStr])
        return TxWithdrawl;
    if([str isEqualToString:GemsTransactionRegBonusStr])
        return TxRegistrationBonus;
    if([str isEqualToString:GemsTransactionInviteBonusStr])
        return TxInvBonus;
    if([str isEqualToString:GemsTransactionMigrationStr])
        return TxMigrate;
    if([str isEqualToString:GemsTransactionAirdropStr])
        return TxAirDrop;
    if([str isEqualToString:GemsTransactionFacebookLikeStr])
        return TxFbLike;
    if([str isEqualToString:GemsTransactionFacebookLoginStr])
        return TxFbLogin;
    if([str isEqualToString:GemsTransactionTwitterLikeStr])
        return TxTwitterLike;
    if([str isEqualToString:GemsTransactionFaucetBonusStr])
        return TxFaucetBonus;
    if([str isEqualToString:GemsTransactionPurchaseStr])
        return TxPurchase;
    if([str isEqualToString:GemsTransactionRateBonusStr])
        return TxAppRating;
    return TxTypeKnown;
}

+ (Currency*)currencyFromSymbol:(NSString*)str
{
    str = [str uppercaseString];
    if([str isEqualToString:@"GEM"] || [str isEqualToString:@"GEMS"])
        return _G;
    
    return _B;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_txId forKey:@"txId"];
    [aCoder encodeObject:@(_type) forKey:@"type"];
    if(_type == TxPurchase)
        [aCoder encodeObject:_storeItem forKey:@"storeItem"];
    [aCoder encodeObject:[_currency symbol] forKey:@"asset"];
    [aCoder encodeInt64:_amount forKey:@"amount"];
    [aCoder encodeObject:_source forKey:@"source"];
    [aCoder encodeObject:_destination forKey:@"destination"];
    [aCoder encodeObject:_timestamp forKey:@"timestamp"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    Transaction *ret = [[Transaction alloc] init];
    ret.txId = [aDecoder decodeObjectForKey:@"txId"];
    ret.type = [((NSNumber*)[aDecoder decodeObjectForKey:@"type"]) longLongValue];
    if(ret.type == TxPurchase)
        ret.storeItem = [aDecoder decodeObjectForKey:@"storeItem"];
    ret.currency = [[aDecoder decodeObjectForKey:@"asset"] isEqualToString:@"gems"] ? _G:_B;
    ret.amount = [aDecoder decodeInt64ForKey:@"amount"];
    ret.source = [aDecoder decodeObjectForKey:@"source"];
    ret.destination = [aDecoder decodeObjectForKey:@"destination"];
    ret.timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
    return ret;
}

@end
