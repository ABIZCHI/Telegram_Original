//
//  Transactions.h
//  GetGems
//
//  Created by alon muroch on 6/10/15.
//
//

#import <Foundation/Foundation.h>
#import "Transaction.h"

@protocol TransactionSorter <NSObject>

- (NSArray*)sort:(NSArray*)transactions;
- (NSDictionary*)group:(NSArray*)transactions;

@end



@interface TransactionsContainer : NSObject

@property(nonatomic, strong) NSMutableArray *transactions;
@property(nonatomic, strong) NSDictionary *groupedTransactions;
@property(nonatomic, strong) NSArray *orderdGroupedTxKeys;

@property(nonatomic, strong) id<TransactionSorter> sorter;
- (void)addTransaction:(Transaction*)tx;
- (void)setTransactions:(NSArray*)txs;

- (void)groupAndSort;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSDateComponents*)dateComponentForSection:(NSInteger)section;
- (Transaction*)transactionForSection:(NSInteger)section row:(NSInteger)row;

@end
