//
//  FeaturedCell.m
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "FeaturedCell.h"
#import "SquareImageCell.h"
#import "GemsStoreCommons.h"
#import "GetGemsCell.h"

@implementation StoreItemData

+ (instancetype)dataFromDictinary:(NSDictionary*)dic
{
    StoreItemData *ret = [[StoreItemData alloc] init];
    ret.itemType = [self itemTypeFromStr:dic[@"typeName"]];
    ret.itemID = dic[@"id"];
    ret.iconURL = dic[@"iconURL"];
    ret.cardURL = dic[@"cardURL"];
    ret.bannerURL = dic[@"bannerURL"];
    ret.title = dic[@"name"];
    ret.categoryStr = @"General";
    ret.descr = dic[@"description"];
    ret.price = [NSNumber numberWithLongLong:[dic[@"price"] longLongValue]];
    ret.currency = _G;
    ret.tos = [dic objectForKey:@"tos"];
    ret.redeemCode = [dic objectForKey:@"code"];
    
    ret.dataAsDictionary = dic;
    
    return ret;
}

+ (StoreItemType)itemTypeFromStr:(NSString*)str
{
    if([str isEqualToString:GemsStoreProductTypeCoupons])
        return StoreItemCoupon;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dataAsDictionary forKey:@"data"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSDictionary *data = [aDecoder decodeObjectForKey:@"data"];
    return [StoreItemData dataFromDictinary:data];
}

@end

@interface FeaturedCell()
{
    NSArray *_data;
    
}


@end

@implementation FeaturedCell

- (void)awakeFromNib {
    _tblViewWrapper = [[PTEHorizontalTableView alloc] init];
    _tblViewWrapper.delegate = self;
        
    _tblView = [[UITableView alloc] init];
    [_tblView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tblView setShowsHorizontalScrollIndicator:NO];
    [_tblView setShowsVerticalScrollIndicator:NO];
    [_tblViewWrapper setTableView:_tblView];
    
    [self addSubview:_tblViewWrapper];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _tblViewWrapper.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _tblView.frame = _tblViewWrapper.frame;
}

+ (CGFloat)cellHeight
{
    return 160.0f;
}

+ (NSString*)cellIdentifier
{
    return @"FeaturedCell";
}

- (void)bindCell:(id)data
{
    _data = (NSArray*)data;
    
    [_tblViewWrapper.tableView reloadData];
}

#pragma mark - PTETableViewDelegate

- (NSInteger)tableView:(PTEHorizontalTableView *)horizontalTableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(PTEHorizontalTableView *)horizontalTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SquareImageCell *cell = (SquareImageCell *)[horizontalTableView.tableView dequeueReusableCellWithIdentifier:[SquareImageCell cellIdentifier]];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SquareImageCell" owner:self options:nil];
        cell = (SquareImageCell *)[nib objectAtIndex:0];
    }
    
    id data = [_data objectAtIndex:indexPath.row];
    cell.indexPath = indexPath;
    
    cell.titleColor = _featureCellTitleColor;
    cell.detailsColor = _featureCellDetailsColor;
    
    [cell bindCell:data];
        
    return cell;
}

- (CGFloat)tableView:(PTEHorizontalTableView *)horizontalTableView widthForCellAtIndexPath:(NSIndexPath *)indexPath{
    return [SquareImageCell cellWidth];
}

- (void)tableView:(PTEHorizontalTableView *)horizontalTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SquareImageCell *cell = (SquareImageCell *)[self tableView:horizontalTableView cellForRowAtIndexPath:indexPath];
    id data = [_data objectAtIndex:indexPath.row];
    
    // do not allow selection of completed tasks
    if([data isMemberOfClass:[GetGemsCellData class]]) {
        GetGemsCellData *cellData = (GetGemsCellData*)data;
        if(cellData.completed)
            return;
    }
    
    if(_delegate)
        [_delegate didSelectCell:cell inContainingCell:self data:data];
}

@end
