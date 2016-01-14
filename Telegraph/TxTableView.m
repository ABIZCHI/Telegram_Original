//
//  ReferralTableView.m
//  GetGems
//
//  Created by alon muroch on 6/3/15.
//
//

#import "TxTableView.h"
#import "TGImageUtils.h"
#import "TGAppDelegate.h"
#import "GemsTelegraphUserInfoController.h"
#import "TxDataSource.h"

// GemsCore
#import <GemsCore/Gems.h>

@interface TxTableView()
{
    TxDataSource *_dataSource;
}

@end


@implementation TxTableView

- (instancetype)init
{
    self = [super init];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _dataSource = [[TxDataSource alloc] init];
    
    self.separatorColor = [UIColor clearColor];
    self.allowsSelection = YES;
    
    self.delegate = self;
    _dataSource.tblView = self; // will bind itself as a datasource

    self.backgroundColor = [UIColor clearColor];
    
    [self setUpGlobalAssetObserver];
    
    [self reloadData];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    [super reloadSections:sections withRowAnimation:animation];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)reloadDataFromServerWithCompletion:(void(^)(NSError *errorc))completion
{
    [_dataSource refreshDataFromServerWithCompletion:completion];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    if(section == 0)
//        header.backgroundView.backgroundColor = [UIColor clearColor];
//    else
    header.backgroundView.backgroundColor = UIColorRGB(0xf1f1f1);
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == ([tableView.dataSource numberOfSectionsInTableView:tableView] - 1))
    {
        if(indexPath.row != ([tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section] - 1))
            return TransactionCellHeight;
        else {
            return [self calculateContentFiller];
        }
    }
    else {
        return TransactionCellHeight;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 0;
    return TxTableSectionViewHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Transaction *tx = [[_dataSource getTransactionsContainerForCurrency:_dataSource.currency] transactionForSection:indexPath.section row:indexPath.row];

    if(!tx) return;
    
    if(_txTableDelegate)
        [_txTableDelegate txTableView:self didSelectTransaction:tx];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_dataSource tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.scrollingDelegateProxy)
        [self.scrollingDelegateProxy scrollViewDidScroll:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(self.scrollingDelegateProxy)
        [self.scrollingDelegateProxy scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

#pragma mark - helpers
- (CGFloat)calculateContentFiller
{
    CGFloat tblHeight = self.frame.size.height;
    CGFloat dataHeight = [self dataHeight];
    CGFloat sectionHeaderHeight = [self tableView:self heightForHeaderInSection:0] * [self.dataSource numberOfSectionsInTableView:self];
    
    return MAX(0, (tblHeight - (dataHeight + sectionHeaderHeight)));
}

- (CGFloat)dataHeight
{
    CGFloat h = 0;
    for(NSInteger i=0 ; i < [self numberOfSections] ; i++) {
        if(i != ([self numberOfSections] - 1))
            h += ([self.dataSource tableView:self numberOfRowsInSection:i] * TransactionCellHeight);
        else
            h += (([self.dataSource tableView:self numberOfRowsInSection:i] - 1) * TransactionCellHeight); // -1 to compensate for filler
    }
    
    return h;
}

#pragma mark - asset observer

- (void)setUpGlobalAssetObserver
{
    Gems *g = [Gems sharedInstance];
    [g addObserver:self forKeyPath:@"globalSelectedCurrency" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"globalSelectedCurrency"]) {
        [_dataSource setCurrency:GEMS.globalSelectedCurrency];

        [self reloadData];
        
//        NSMutableIndexSet *is = [[NSMutableIndexSet alloc] init];
//        for(NSUInteger i = 0 ; i < [_dataSource numberOfSectionsInTableView:self] ; i++)
//            [is addIndex:i];
        
//        UITableViewRowAnimation anim;
//        if([[Gems sharedInstance].globalSelectedDigitalAsset isEqualToString:BITCOIN_ASSET])
//            anim = UITableViewRowAnimationLeft;
//        else
//            anim = UITableViewRowAnimationRight;
//        [self reloadSections:is withRowAnimation:anim];
    }
}

@end
