//
//  ReferralTableView.h
//  GetGems
//
//  Created by alon muroch on 6/3/15.
//
//

#import <UIKit/UIKit.h>
#import "TransactionCell.h"
#import "TxInfoHeaderView.h"

static CGFloat TxTableSectionViewHeight = 35.0f;

@class TxTableView;

@protocol TxTableViewDelegate

- (void)txTableView:(TxTableView*)tableView didSelectTransaction:(Transaction*)transaction;

@end

@interface TxTableView : UITableView <UITableViewDelegate>

@property(nonatomic, strong) id<UIScrollViewDelegate> scrollingDelegateProxy;
@property(nonatomic, strong) id<TxTableViewDelegate> txTableDelegate;

@property(nonatomic, strong) TxInfoHeaderView *headerView;

- (void)reloadDataFromServerWithCompletion:(void(^)(NSError *errorc))completion;

@end
