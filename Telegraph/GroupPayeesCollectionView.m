//
//  GroupPayeesCollectionView.m
//  GetGems
//
//  Created by alon muroch on 7/14/15.
//
//

#import "GroupPayeesCollectionView.h"
#import "GroupPayeeCollectionCell.h"

// GemsUI
#import <GemsUI/UIImage+Loader.h>

// GemsCore
#import <GemsCore/Macros.h>

@interface GroupPayeesCollectionView()
{
    BOOL _showSelectAll;
    UIImage *_imgSelectOption;
    
    BOOL _isShowingSelectAll;
}
@end

@implementation GroupPayeesCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self = [super initWithFrame:frame collectionViewLayout:flowLayout];
    if(self)
    {
        self.dataSource = self;
        self.delegate = self;
        self.backgroundColor = [UIColor clearColor];
        [self registerNib:[UINib nibWithNibName:@"GroupPayeeCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:GroupPayeeCollectionCellIdentifier];
        
        _imgSelectOption = [UIImage Loader_gemsImageWithName:@"unselect_all"];
        _isShowingSelectAll = false;
    }
    return self;
}

- (void)setPrContainer:(PaymentRequestsContainer *)prContainer
{
    _prContainer = prContainer;
    _selectedPaymentRequests = [NSMutableArray arrayWithArray:_prContainer.paymentRequests];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    int count = _prContainer.paymentRequests.count;
    _showSelectAll = count > 1? YES:NO;
    
    return count + (_showSelectAll? 1:0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GroupPayeeCollectionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:GroupPayeeCollectionCellIdentifier forIndexPath:indexPath];

    if(_showSelectAll && indexPath.row == 0)
    {
        [cell.iv loadImage:_imgSelectOption];
        [cell.iv setTitle:@""];
        cell.imgViewContainer.backgroundColor = [UIColor clearColor];
        [cell.lbl setAttributedTitle:[NSAttributedString new] forState:UIControlStateNormal];
        return cell;
    }
    
    PaymentRequest *pr = _prContainer.paymentRequests[_showSelectAll ? (indexPath.row - 1):indexPath.row];
    [cell bindCellForPaymentRequest:pr];
    
    if([_selectedPaymentRequests containsObject:pr])
        cell.imgViewContainer.backgroundColor = UIColorRGB(0x007df2);
    else
        cell.imgViewContainer.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 70);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0.0;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 5, 10, 5);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        if(!_isShowingSelectAll)
        {
            _selectedPaymentRequests = [[NSMutableArray alloc] init];
            _imgSelectOption = [UIImage Loader_gemsImageWithName:@"select_all"];
            _isShowingSelectAll = YES;
        }
        else {
            _selectedPaymentRequests = [NSMutableArray arrayWithArray:_prContainer.paymentRequests];
            _imgSelectOption = [UIImage Loader_gemsImageWithName:@"unselect_all"];
            _isShowingSelectAll = NO;
        }
    }
    else
    {
        __weak typeof(PaymentRequest) *pr = _prContainer.paymentRequests[indexPath.row - 1];
        if([_selectedPaymentRequests containsObject:pr])
            [_selectedPaymentRequests removeObject:pr];
        else
            [_selectedPaymentRequests addObject:pr];
    }
    //
    if(_selectionChanged)
        _selectedPaymentRequests = [NSMutableArray arrayWithArray:_selectionChanged(_selectedPaymentRequests)];
    
    [self reloadData];
}

@end
