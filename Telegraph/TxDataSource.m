//
//  TxDataSource.m
//  GetGems
//
//  Created by alon muroch on 6/10/15.
//
//

#import "TxDataSource.h"
#import "TGGemsWallet.h"
#import "TransactionCell.h"
#import "Transaction.h"
#import "MonthSorter.h"
#import "TxFillerCell.h"
#import "LoadMoreTableViewCell.h"

// GemsUI
#import <GemsUI/UserNotifications.h>

#define CACHED_TRANSACTION_DATA @"CACHED_TRANSACTION_DATA"
#define LAST_FETCHED_DATA_UNIX @"LAST_FETCHED_DATA_UNIX"

#define FETCH_TRANSACTIONS_LIMIT 50

@interface TxDataSource()
{
    MonthSorter *_txSorter;
    
    BOOL _shouldShowLoadMoreCell;
}

@end

@implementation TxDataSource

- (instancetype)init
{
    self = [super init];
    if(self) {
        _txSorter = [[MonthSorter alloc] init];
        
        _currency = _G;
        
        NSDictionary *allTx = [self loadTransactionsFromDefaults];
        _transactionsByCurrency = [self allTxToContainersByCurrency:allTx];
        [_tblView reloadData];
    }
    return self;
}

- (NSDictionary*)allTxToContainersByCurrency:(NSDictionary*)allTx
{
    // gems
    TransactionsContainer *containerGems = [[TransactionsContainer alloc] init];
    containerGems.sorter = _txSorter;
    if(!allTx[[_G symbol]])
        [containerGems setTransactions:@[]];
    else
        [containerGems setTransactions:allTx[[_G symbol]]];
    [containerGems groupAndSort];
    // btc
    TransactionsContainer *containerBtc = [[TransactionsContainer alloc] init];
    containerBtc.sorter = _txSorter;
    if(!allTx[[_B symbol]])
        [containerBtc setTransactions:@[]];
    else
        [containerBtc setTransactions:allTx[[_B symbol]]];
    [containerBtc groupAndSort];
    return @{ [_G symbol]: containerGems,
                              [_B symbol] : containerBtc};
}

- (void)refreshDataFromServerWithCompletion:(void(^)(NSError *errorc))completion
{
    // bitcoin transactions
    if([_B isActive])
        [_B txHistoryWithOffset:0 limit:0 startUnixTime:0 completion:^(NSArray *transactions, NSString *error) {
            if(error) {
                [UserNotifications showUserMessage:error];
                return ;
            }
            
            NSMutableArray *data = [NSMutableArray new];
            for(BRTransaction *brtx in transactions) {
                Transaction *tx = [Transaction transactionFromBRTransactionObject:brtx];
                if(tx)
                    [data addObject:tx];
            }
            [self addTransactionsToDefaults:data];
            [_tblView reloadData];
        }];
    
    
    // gems transactions
    [self fetchDataFromServerWithCompletion:^(NSArray *data) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(NSDictionary *d in data)
        {
            Transaction *tx = [Transaction transactionFromDictionary:d];
            if(tx)
                [arr addObject:tx];
        }
        
        [self addTransactionsToDefaults:arr];
        
        NSDictionary *allTx = [self loadTransactionsFromDefaults];
        _transactionsByCurrency = [self allTxToContainersByCurrency:allTx];
        
        TransactionsContainer *containerGems = _transactionsByCurrency[[_G symbol]];
        [self setLastUpdateTimeToDefaults:[((Transaction*)[containerGems.transactions lastObject]).timestamp timeIntervalSince1970]];
        
        if(_currency == _G)
        {
            if(allTx.count > 0)
                _shouldShowLoadMoreCell = YES;
            else
                _shouldShowLoadMoreCell = NO;
        }
        else
            _shouldShowLoadMoreCell = NO; // do not show load more for bitcoin
        
        [_tblView reloadData];
        
        if(completion)
            completion(nil);
    }];
}

- (void)fetchDataFromServerWithCompletion:(void(^)(NSArray *data))completion
{
    NSTimeInterval t = round([self loadLastUpdateTimeFromDefaults]);
    int offset = -1, limit = -1;
    if(t == 0) // no data
    {
        offset = 0;
        limit = FETCH_TRANSACTIONS_LIMIT;
    }
    else
        t -= 60*60*24; // a day before
    
    [_G txHistoryWithOffset:offset limit:limit startUnixTime:t completion:^(NSArray *transactions, NSString *error) {
        if(error) {
            [UserNotifications showUserMessage:error];
            return ;
        }
        
        if(completion)
            completion(transactions);
    }];
}

- (NSTimeInterval)loadLastUpdateTimeFromDefaults
{
    return NSDefaultOrZero(LAST_FETCHED_DATA_UNIX);
}

- (void)setLastUpdateTimeToDefaults:(NSTimeInterval)time
{
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:@(time)];
    [[NSUserDefaults standardUserDefaults] setObject:d forKey:LAST_FETCHED_DATA_UNIX];
}

- (void)addTransactionsToDefaults:(NSArray*)data
{
    NSDictionary *d = [self loadTransactionsFromDefaults];
    NSMutableArray *txsToStore = [NSMutableArray arrayWithArray:d[[_G symbol]]];
    [txsToStore addObjectsFromArray:d[[_B symbol]]];
    for(Transaction *t in data)
    {
        NSUInteger idx = [txsToStore indexOfObjectPassingTest:^BOOL(Transaction *obj, NSUInteger idx, BOOL *stop) {
            return [obj.txId isEqual:t.txId];
        }];
        
        if(idx == NSNotFound)
            [txsToStore addObject:t];
        else
        {
            [txsToStore replaceObjectAtIndex:idx withObject:t]; // update
        }
    }
    
    NSData *dic = [NSKeyedArchiver archivedDataWithRootObject:txsToStore];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:CACHED_TRANSACTION_DATA];
}

- (NSDictionary*)loadTransactionsFromDefaults
{
    NSArray *arr = NSDefaultOrEmptyArray(CACHED_TRANSACTION_DATA);
    
    NSMutableArray *arrGems = [[NSMutableArray alloc] init], *arrBTC = [[NSMutableArray alloc] init];
    for(Transaction *tx in arr)
    {
        if(tx.type == TxTypeKnown) continue; // we do not display unsupported tx
        
        if(tx.currency == _G)
            [arrGems addObject:tx];
        else
            [arrBTC addObject:tx];
    }
    
    return @{[_G symbol]: arrGems,
             [_B symbol] : arrBTC};
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    TransactionsContainer *c = [self getTransactionsContainerForCurrency:_currency];
    return MAX(1, [c numberOfSections]); // at least 1 section, if there is no data show the filler cell
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TransactionsContainer *c = [self getTransactionsContainerForCurrency:_currency];
    NSInteger cnt = [c numberOfItemsInSection:section];
    if (section == ([self numberOfSectionsInTableView:tableView] - 1)) {
        return cnt + 1 + (_shouldShowLoadMoreCell? 1:0); // 1 is the filler and the other is the loading more cell (only if there are cells)
    }
    else
        return cnt;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Recent";
    
    NSDateComponents *c = [self dateComponentForSection:section];
    NSDateComponents *componentsToday = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSString *monthName = [[df monthSymbols] objectAtIndex:(c.month-1)];
    if(c.year == componentsToday.year) {
        return monthName;
    }
    
    return [NSString stringWithFormat:@"%@ %ld", monthName, (long)c.year];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionsContainer *c = [self getTransactionsContainerForCurrency:_currency];
    if(_shouldShowLoadMoreCell)
        if(indexPath.section == ([self numberOfSectionsInTableView:tableView] - 1) && indexPath.row == ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 2))
        {
            return [self getLoadingMoreCell:tableView];
        }
    
    if(indexPath.section == ([self numberOfSectionsInTableView:tableView] - 1) && indexPath.row == ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 1))
    {
        if([c numberOfItemsInSection:0] == 0)
            return [self getNoDataFillerCellForTableView:tableView];
        else
            return [self getSpaceFillerCellForTableView:tableView];
    }
    
    TransactionCell *cell = (TransactionCell *)[tableView dequeueReusableCellWithIdentifier:TransactionCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TransactionCell" owner:self options:nil];
        cell = (TransactionCell *)[nib objectAtIndex:0];
    }
    
    Transaction *tx = [c transactionForSection:indexPath.section row:indexPath.row];
    cell.iv.fadeTransition = NO;
    [cell bindCellWithTransaction:tx];
    cell.userInteractionEnabled = YES;
    return cell;
}

- (NSDateComponents*)dateComponentForSection:(NSInteger)section
{
    TransactionsContainer *c = [self getTransactionsContainerForCurrency:_currency];
    return [c dateComponentForSection:section];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_shouldShowLoadMoreCell)
        if(indexPath.section == ([self numberOfSectionsInTableView:tableView] - 1) && indexPath.row == ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 2))
        {
            if(_currency == _G)
                [self loadMoreDataFromServerWithCompletion:^(NSArray *data) {
                    if(data.count == 0)
                    {
                        _shouldShowLoadMoreCell = NO;
                        [_tblView reloadData];
                        return;
                    }
                    
                    NSMutableArray *arr = [[NSMutableArray alloc] init];
                    for(NSDictionary *d in data)
                        [arr addObject:[Transaction transactionFromDictionary:d]];
                    
                    [self addTransactionsToDefaults:arr];
                    
                    NSDictionary *allTx = [self loadTransactionsFromDefaults];
                    _transactionsByCurrency = [self allTxToContainersByCurrency:allTx];
                    
                    _shouldShowLoadMoreCell = YES;
                    [_tblView reloadData];
                }];
        }
}

- (void)loadMoreDataFromServerWithCompletion:(void(^)(NSArray *data))completion
{
    TransactionsContainer *c = [self getTransactionsContainerForCurrency:_currency];
    int offset = (int)c.transactions.count;
    [_G txHistoryWithOffset:offset limit:FETCH_TRANSACTIONS_LIMIT startUnixTime:0 completion:^(NSArray *transactions, NSString *error) {
        if(error) {
            [UserNotifications showUserMessage:error];
            return ;
        }
        
        if(completion)
            completion(transactions);
    }];
}

- (TransactionsContainer*)getTransactionsContainerForCurrency:(Currency*)currency
{
    return [_transactionsByCurrency objectForKey:[currency symbol]];
}

#pragma mark - utils
- (TxFillerCell*)getSpaceFillerCellForTableView:(UITableView*)tableView
{
    TxFillerCell *cell = [tableView dequeueReusableCellWithIdentifier:TxFillerCellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TxFillerCell" owner:self options:nil];
        cell = (TxFillerCell *)[nib objectAtIndex:0];
    }
    
    cell.lbl.text = @"";
    cell.backgroundColor = [UIColor whiteColor];
    cell.userInteractionEnabled = NO;
    cell.lbl.textColor = TGAccentColor();
    
    return cell;
}

- (TxFillerCell*)getNoDataFillerCellForTableView:(UITableView*)tableView
{
    TxFillerCell *cell = [self getSpaceFillerCellForTableView:tableView];
    cell.lbl.text = @"No Transactions";
    cell.lbl.textColor = [UIColor blackColor];
    cell.lbl.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (LoadMoreTableViewCell*)getLoadingMoreCell:(UITableView*)tableView
{
    LoadMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreTableViewCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoadMoreTableViewCell" owner:self options:nil];
        cell = (LoadMoreTableViewCell *)[nib objectAtIndex:0];
    }
    
    return cell;
}

- (void)setTblView:(UITableView *)tblView
{
    _tblView = tblView;
    _tblView.dataSource = self;
}

#pragma mark - setters

- (void)setCurrency:(Currency *)currency
{
    _currency = currency;
    if(_currency == _B)
        _shouldShowLoadMoreCell = NO;
    else
        _shouldShowLoadMoreCell = YES;
}

#pragma mark - Cache clear
+ (void)removeAllCachedTxs
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CACHED_TRANSACTION_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_FETCHED_DATA_UNIX];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeGemsCachedTx
{
    NSArray *arr = NSDefaultOrEmptyArray(CACHED_TRANSACTION_DATA);
    NSMutableArray *arrBTC = [[NSMutableArray alloc] init];
    for(Transaction *tx in arr)
    {
        if(tx.currency == _B)
          [arrBTC addObject:tx];
    }
    
    [self removeAllCachedTxs];
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:arrBTC];
    [[NSUserDefaults standardUserDefaults] setObject:d forKey:CACHED_TRANSACTION_DATA];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_FETCHED_DATA_UNIX];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeBitcoinCachedTx
{
    NSArray *arr = NSDefaultOrEmptyArray(CACHED_TRANSACTION_DATA);
    NSMutableArray *arrGems = [[NSMutableArray alloc] init];
    for(Transaction *tx in arr)
    {
        if(tx.currency == _G)
            [arrGems addObject:tx];
    }
    
    [self removeAllCachedTxs];
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:arrGems];
    [[NSUserDefaults standardUserDefaults] setObject:d forKey:CACHED_TRANSACTION_DATA];
}


@end
