//
//  BalancesView.m
//  GetGems
//
//  Created by alon muroch on 5/19/15.
//
//

#import "BalancesView.h"
#import "TGCommon.h"

// GemsUI
#import <GemsUI/UIColor+CrossFade.h>

// GemsCore
#import <GemsCore/GemsCD.h>

@implementation BalanceObject

@end

@implementation BalanceView

+(BalanceView*)viewFromBalanceObject:(BalanceObject*)obj
{
    BalanceView *ret = [[BalanceView alloc] init];
    ret.obj = obj;
    
    return ret;
}

- (instancetype)init
{
    self = [super init];
    if(self) {
        _lblCrypto = [[UICountingLabel alloc] init];
        _lblCrypto.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:90.0f];
        _lblCrypto.textColor = [GemsAppearance navigationTextColor];
        _lblCrypto.textAlignment = NSTextAlignmentCenter;
        _lblCrypto.method = UILabelCountingMethodLinear;
        _lblCrypto.adjustsFontSizeToFitWidth = YES;
        _lblCrypto.minimumScaleFactor = 0.1f;
        _lblCrypto.format = @"%.2g";
        _lblCrypto.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _lblCrypto.formatBlock = ^NSString* (double value)
        {
            return [NSString stringWithFormat:@"%@",formatDoubleToStringWithDecimalPrecision(value, [self decimalPrecision])];
        };
        [self addSubview:_lblCrypto];
        
        _lblFiat = [[UICountingLabel alloc] init];
        _lblFiat.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
        _lblFiat.textColor = [GemsAppearance navigationTextColor];
        _lblFiat.textAlignment = NSTextAlignmentCenter;
        _lblFiat.method = UILabelCountingMethodLinear;
        _lblFiat.adjustsFontSizeToFitWidth = YES;
        _lblFiat.minimumScaleFactor = 0.1f;
        _lblFiat.format = @"%.2g";
        _lblFiat.formatBlock = ^NSString* (double value)
        {
            return [NSString stringWithFormat:@"%@ %@", formatDoubleToStringForFiatAmount(value), [self getFiatCode]];
        };
        [self addSubview:_lblFiat];
    }
    return self;
}

- (void)layoutSubviews
{
    _lblCrypto.frame = CGRectMake(0,
                                  10,
                                  self.frame.size.width,
                                  self.frame.size.height * 4/5 - 10);
    _lblFiat.frame = CGRectMake(0,
                                self.frame.size.height * 4/5 + 5,
                                self.frame.size.width,
                                self.frame.size.height * 1/5);
}

-(NSString*)getFiatCode
{
    CDGemsSystem *s = [CDGemsSystem MR_findFirst];
    return [s.currencySymbol uppercaseString];
}

- (void)refreshCryptoValueToValue:(NSNumber*)newValue
{
    if([self currency] == _B)
        _lblCrypto.sideIcon = sysBtcUnitIconWithSpacing([GemsAppearance navigationTextColor], @" ", @" "); // show current system icon
    [self refreshCryptoValueFromValue:[NSNumber numberWithDouble:_lblCrypto.currentValue] toValue:newValue];
}

- (void)refreshCryptoValueFromValue:(NSNumber*)fromValue toValue:(NSNumber*)newValue
{
    [_lblCrypto countFrom:[fromValue doubleValue] to:[newValue doubleValue]];
    
    double newFiat, oldFiat;
    if([self currency] == _G) {
        GemsAmount *ga = [[GemsAmount alloc] initWithAmount:[newValue doubleValue] currency:[self currency] unit:Gem];
        newFiat = [[ga toFiat:[self getFiatCode]] doubleValue];
        
        ga = [[GemsAmount alloc] initWithAmount:[fromValue doubleValue] currency:[self currency] unit:Gem];
        oldFiat = [[ga toFiat:[self getFiatCode]] doubleValue];
    }
    else {
        GemsAmount *ga = [[GemsAmount alloc] initWithAmount:[[newValue CD_sysUnitToSatoshi] doubleValue] currency:[self currency] unit:Satoshies];
        newFiat = [[ga toFiat:[self getFiatCode]] doubleValue];
        
        ga = [[GemsAmount alloc] initWithAmount:[[fromValue CD_sysUnitToSatoshi] doubleValue] currency:[self currency] unit:Satoshies];
        oldFiat = [[ga toFiat:[self getFiatCode]] doubleValue];
    }
    
    [_lblFiat countFrom:oldFiat to:newFiat];
}

#pragma mark - BalanceObj methods

- (void)setObj:(BalanceObject *)obj
{
    _obj = obj;
    
    _lblCrypto.sideIcon = _obj.assetIcon;
    
    [self refreshCryptoValueFromValue:[self startingValue] toValue:[self startingValue]];
}

- (NSString *)cryptoSuffix
{
    return _obj.cryptoSuffix;
}

- (Currency *)currency
{
    return _obj.currency;
}

- (NSNumber *)startingValue
{
    return _obj.startingValue;
}

- (NSUInteger)decimalPrecision
{
    if([self currency] == _B) {
        CDGemsSystem *sys = [CDGemsSystem MR_findFirst];
        if([sys.bitcoinDenomination intValue] == Btc)
            return 3;
        return sysDecimalPrecisionForUI([self currency]);
    }
    return 0; // force 0 for gems
}

@end

@interface BalancesView()
{

}
@end

@implementation BalancesView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

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
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.delegate = self;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPageIndicatorTintColor = [GemsAppearance navigationTextColor];
    _pageControl.pageIndicatorTintColor = UIColorRGB(0xa1a1a1);
    [_pageControl setCurrentPage:0];
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
    
    _arrBalances = @[];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _scrollView.frame = CGRectMake(10, 0, self.frame.size.width - 20, self.frame.size.height - 15);
    _pageControl.frame = CGRectMake(10, self.frame.size.height - 10, self.frame.size.width - 20, 30);
    
    int pageNumber = 0;
    for(UIView *v in _scrollView.subviews) {
        if([v isKindOfClass:[BalanceView class]]) {
            CGFloat x = pageNumber * _scrollView.frame.size.width;
            v.frame = CGRectMake(x, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
            [v layoutSubviews];
            ((BalanceView*)v).pageNumber = pageNumber;
            
            pageNumber ++;
        }
    }
    _scrollView.contentSize = CGSizeMake(pageNumber * _scrollView.frame.size.width, _scrollView.frame.size.height);
    [self scrollToPage:_pageControl.currentPage animated:YES];
}

#pragma mark - balance view

- (void)addBalances:(NSArray*)arr
{
    _arrBalances = [_arrBalances arrayByAddingObjectsFromArray:arr];
    [self reAddBalances];
}

- (void)clearAll
{
    _arrBalances = @[];
    [self reAddBalances];
}

- (void)reAddBalances
{
    for(UIView *v in _scrollView.subviews)
        if([v isKindOfClass:[BalanceView class]])
            [v removeFromSuperview];
    
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for(BalanceObject *obj in _arrBalances) {
        UIView *v = [BalanceView viewFromBalanceObject:obj];
        [views addObject:v];
        [_scrollView addSubview:v];
    }
    
    _pageControl.numberOfPages = _arrBalances.count;
    
    [self setNeedsLayout];
}

- (void)refreshCurrency:(Currency*)currency withNewValue:(NSNumber*)newValue
{
    for(UIView *v in _scrollView.subviews)
        if([v isKindOfClass:[BalanceView class]]) {
            BalanceView *bv = (BalanceView*)v;
            if(!([bv currency] == currency))
                continue;
            
            [bv refreshCryptoValueToValue:newValue];
            break;
        }
}

- (void)scrollToPage:(int)idx animated:(BOOL)animated
{
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * idx;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:animated];
    [self notifyDelegateOfCurrentView];
}

- (void)scrollToCurrency:(Currency*)currency animated:(BOOL)animated
{
    for(UIView *v in _scrollView.subviews)
        if([v isKindOfClass:[BalanceView class]]) {
            BalanceView *bv = (BalanceView*)v;
            if(!([bv currency] == currency))
            {
                [self scrollToPage:bv.pageNumber animated:animated];
            }
        }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    {
        int width = scrollView.frame.size.width;
        float xPos = scrollView.contentOffset.x + 1;
        _pageControl.currentPage = (int)roundf((float)xPos/(float)width);
    }
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    [self notifyDelegateOfCurrentView];
//}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self notifyDelegateOfCurrentView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self notifyDelegateOfCurrentView];
}

#pragma mark - helper methods

- (int)currentScrollViewPage
{
    int width = _scrollView.frame.size.width;
    float xPos = _scrollView.contentOffset.x+10;
    return (int)xPos/width;
}

- (int)inWhatPageDoWeScroll
{
    CGFloat bottom, top;
    float xPos = _scrollView.contentOffset.x;
    for(UIView *v in _scrollView.subviews)
        if([v isKindOfClass:[BalanceView class]]) {
            BalanceView *bv = (BalanceView*)v;
            bottom = bv.frame.origin.x;
            top = bottom + bv.frame.size.width;
            if(xPos >= bottom && xPos <= top) {
                return bv.pageNumber;
            }
        }
    
    return 0; // in case of negative offset values
}

- (CGFloat)pagingScrollCompletion
{
    CGFloat bottom, top;
    for(UIView *v in _scrollView.subviews)
        if([v isKindOfClass:[BalanceView class]]) {
            BalanceView *bv = (BalanceView*)v;
            if(bv.pageNumber == [self inWhatPageDoWeScroll]) {
                bottom = bv.bounds.origin.x;
                top = bottom + bv.bounds.size.width;
                float xPos = _scrollView.contentOffset.x;
                
                return MIN(MAX(xPos / top, 0), 1) ; // no values greater than 1 or lower than 0
                
            }
        }
    
    return 1;
}

- (BalanceView*)getBalanceViewByPageNumber:(int)idx
{
    for(UIView *v in _scrollView.subviews)
        if([v isKindOfClass:[BalanceView class]]) {
            BalanceView *bv = (BalanceView*)v;
            if(bv.pageNumber == idx) {
                return bv;
            }
        }
    return nil;
}

- (void)notifyDelegateOfCurrentView
{
    BalanceView *p = [self getBalanceViewByPageNumber:[self currentScrollViewPage]];
    if(_delegate)
        [_delegate chnagedToBalanceView:p];
}

@end
