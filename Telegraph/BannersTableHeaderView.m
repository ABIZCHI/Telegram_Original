//
//  BannersTableHeaderView.m
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "BannersTableHeaderView.h"

#import "GetGemsCell.h"
#import "SquareImageCell.h"
#import "StoreTableViewDataSource.h"

#define BANNER_STARTING_TAG_IDX 1000

@interface BannersTableHeaderView()
{
    NSArray *_data;
    UIScrollView *_scrllView;
    //                                      1 = right, 0 = left
    NSInteger _currentDisplayingBanner, _autoScrollingDirection;
    
    NSTimer *_timer;
}

@end

@implementation BannersTableHeaderView

- (instancetype)init
{
    self = [super init];
    if(self) {
        _scrllView = [[UIScrollView alloc] init];
        _scrllView.delegate = self;
        _scrllView.pagingEnabled = YES;
        [self addSubview:_scrllView];
        
        _autoScrollingDirection = 1;
        _currentDisplayingBanner = 0;
        
        [_scrllView setShowsHorizontalScrollIndicator:NO];
        [_scrllView setShowsVerticalScrollIndicator:NO];
    }
    return self;
}

+ (CGFloat)height
{
    return 150.0f;
}

- (void)bind:(id)data
{
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    _data = (NSArray*)data;
    
    for(UIView *v in _scrllView.subviews)
        if(v.tag >= BANNER_STARTING_TAG_IDX)
            [v removeFromSuperview];
    
    int idx = 0;
    for(GetGemsCellData *d in _data) {
        UIImageView *iv = [[UIImageView alloc] init];
        iv.tag = BANNER_STARTING_TAG_IDX + idx;
        [_scrllView addSubview:iv];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        [iv sd_setImageWithURL:[NSURL URLWithString:d.bannerURL]];
        idx ++;
    }

    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTap:)];
    rec.numberOfTapsRequired = 1;
    rec.numberOfTouchesRequired = 1;
    [_scrllView addGestureRecognizer:rec];
    
    _timer = [NSTimer timerWithTimeInterval:4.0f target:self selector:@selector(pageBanner:) userInfo:nil repeats:YES] ;
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    [self setNeedsLayout];
}

- (void)bannerTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    GetGemsCellData *d = _data[_currentDisplayingBanner];
    
    if(d.completed) return;
    
    // simpulate cells
    AppStoreCellBase *containing = [AppStoreCellBase new];
    containing.indexPath = [NSIndexPath indexPathForItem:0 inSection:StoreGetGemsSection];
    SquareImageCell *cell = [SquareImageCell new];
    cell.data = d;
    
    if(_delegate)
        [_delegate didSelectCell:cell inContainingCell:containing data:d];
}

- (void)freezeMovmentForOffset:(CGFloat)offset
{
    // make sure the table header doesnt scroll down
    if(offset > 0)
    {
        CGRect r = _scrllView.frame;
        r.origin.y = -offset;
        _scrllView.frame = r;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _scrllView.frame = self.frame;
    
    CGFloat xOffset = 0.0f;
    for(UIView *v in _scrllView.subviews)
        if(v.tag >= BANNER_STARTING_TAG_IDX) {
            v.frame = CGRectMake(xOffset, 0, _scrllView.frame.size.width, _scrllView.frame.size.height);
            xOffset += _scrllView.frame.size.width;
        }
    _scrllView.contentSize = CGSizeMake(xOffset, _scrllView.frame.size.height);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int width = scrollView.frame.size.width;
    float xPos = scrollView.contentOffset.x+10;
    NSInteger nextIdx = (int)xPos/width;
    
    if(nextIdx != _currentDisplayingBanner)
        if(nextIdx < _currentDisplayingBanner)
            _autoScrollingDirection = 0;
        else
            _autoScrollingDirection = 1;
    
    _currentDisplayingBanner = nextIdx;
}

#pragma mark - timer
- (void)pageBanner:(NSTimer *)timer
{
    NSInteger nextIdx = _currentDisplayingBanner;
    if(_autoScrollingDirection == 0)
        nextIdx --;
    else
        nextIdx ++;
        
    if(nextIdx >= _data.count) {
        nextIdx = _currentDisplayingBanner - 1;
        _autoScrollingDirection = 0;
    }
    
    if(nextIdx < 0) {
        nextIdx = _currentDisplayingBanner + 1;
        _autoScrollingDirection = 1;
    }
    
    // scroll to page
    CGRect frame = _scrllView.frame;
    frame.origin.x = frame.size.width * nextIdx;
    frame.origin.y = 0;
    [_scrllView scrollRectToVisible:frame animated:YES];
}

@end
