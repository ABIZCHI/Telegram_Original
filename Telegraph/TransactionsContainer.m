//
//  Transactions.m
//  GetGems
//
//  Created by alon muroch on 6/10/15.
//
//

#import "TransactionsContainer.h"


@interface TransactionsContainer ()
{
    
}

@end

@implementation TransactionsContainer

- (instancetype)init
{
    self = [super init];
    if(self) {
        _transactions = [[NSMutableArray alloc] init];
        _groupedTransactions = @{};
        _orderdGroupedTxKeys = @[];
    }
    return self;
}

- (void)addTransaction:(Transaction*)tx
{
    @synchronized(_transactions) {
        [_transactions addObject:tx];
    }
}

- (void)setTransactions:(NSArray*)txs
{
    _transactions = [NSMutableArray arrayWithArray:txs];
}

- (NSInteger)numberOfSections
{
    return _orderdGroupedTxKeys.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    int cnt = _orderdGroupedTxKeys.count;
    if(section > (cnt - 1)) return 0;
    
    NSDateComponents *c = [_orderdGroupedTxKeys objectAtIndex:section];
    NSArray *txs = [_groupedTransactions objectForKey:c];
    return txs.count;
}

- (Transaction*)transactionForSection:(NSInteger)section row:(NSInteger)row
{
    if(section >= _orderdGroupedTxKeys.count) return nil;
    
    NSDateComponents *c = [_orderdGroupedTxKeys objectAtIndex:section];
    NSArray *txs = [_groupedTransactions objectForKey:c];
    
    if(row >= txs.count) return nil;
    return [txs objectAtIndex:row];
}

- (NSDateComponents*)dateComponentForSection:(NSInteger)section
{
    NSDateComponents *c = [_orderdGroupedTxKeys objectAtIndex:section];
    return c;
}

- (void)groupAndSort
{
    _transactions = [_sorter sort:_transactions];
    _groupedTransactions = [_sorter group:_transactions];
    _orderdGroupedTxKeys = [self orderDictionaryWithNSDateComponentsAsKeys:_groupedTransactions];
}

- (NSArray*)orderDictionaryWithNSDateComponentsAsKeys:(NSDictionary*)data
{
    NSArray *keys = [data allKeys];
    NSArray *ret = [keys sortedArrayUsingComparator:^NSComparisonResult(NSDateComponents *obj1, NSDateComponents *obj2) {
        NSCalendar *cal = [NSCalendar currentCalendar];
        
        NSDate *o1 = [cal dateFromComponents:obj1];
        NSDate *o2 = [cal dateFromComponents:obj2];
        
        return [o2 compare:o1];
    }];
    
    return ret;
}


@end
