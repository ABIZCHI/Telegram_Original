//
//  GemsAttachmentSheetHorizontalImageButtonsView.m
//  GetGems
//
//  Created by alon muroch on 5/4/15.
//
//

#import "GemsAttachmentSheetHorizontalImageButtonsView.h"

#define itemSize 100

@implementation GemsAttachmentSheetHorizontalImageButtonsView

- (instancetype)init
{
    self = [super init];
    if(self) {
        _scrlView = [[UIScrollView alloc] init];
        [_scrlView setShowsHorizontalScrollIndicator:NO];
        [_scrlView setShowsVerticalScrollIndicator:NO];
        _scrlView.delegate = self;
        [self addSubview:_scrlView];
        _items = [[NSMutableArray alloc] init];
    }
    
    [self setShowsBottomSeparator:NO];
    [self setShowsTopSeparator:NO];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _scrlView.frame = self.bounds;
    _scrlView.contentSize = (CGSize){ itemSize * _items.count, self.frame.size.height};
    
    for(int i =0; i < _items.count; i++)
    {
        TGAttachmentSheetItemView *v = [_items objectAtIndex:i];
        CGPoint p = (CGPoint){itemSize * i, 0};
        CGSize  s = (CGSize) {itemSize, itemSize};
        v.frame = (CGRect){p, s};
        [v layoutSubviews];
    }
}

- (CGFloat)preferredHeight
{
    return itemSize;
}

- (void)addItem:(TGAttachmentSheetItemView*)item
{
    [_items addObject:item];
    [_scrlView addSubview:item];
}

#pragma mark - UIScrollDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender.contentOffset.y != 0) {
        CGPoint offset = sender.contentOffset;
        offset.y = 0;
        sender.contentOffset = offset;
    }
}

@end
