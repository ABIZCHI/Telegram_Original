//
//  TxDataSource.h
//  GetGems
//
//  Created by alon muroch on 6/10/15.
//
//

#import <Foundation/Foundation.h>
#import "TransactionsContainer.h"

// Currencies
#import <GemsCurrencyManager/GemsCurrencyManager.h>

@interface TxDataSource : NSObject <UITableViewDataSource>

@property(nonatomic, weak) UITableView *tblView;

@property (nonatomic, strong) Currency *currency;
@property (nonatomic, strong) NSDictionary *transactionsByCurrency;

+ (void)removeAllCachedTxs;
+ (void)removeGemsCachedTx;
+ (void)removeBitcoinCachedTx;

- (NSDateComponents*)dateComponentForSection:(NSInteger)section;
- (void)refreshDataFromServerWithCompletion:(void(^)(NSError *errorc))completion;

// 
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

//
- (TransactionsContainer*)getTransactionsContainerForCurrency:(Currency*)currency;

@end
