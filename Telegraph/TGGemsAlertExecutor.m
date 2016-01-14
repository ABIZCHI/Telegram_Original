//
//  TGGemsAlertExecutor.m
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import "TGGemsAlertExecutor.h"
#import "FXBlurView.h"

#import "GemsAlert.h"
#import "GemsAlertViewBase.h"
#import "GemsAlertCenter.h"

#import <QuartzCore/QuartzCore.h>

@interface TGGemsAlertExecutor() <UIScrollViewDelegate>
{
    BOOL _isDisplayingAlerts;
    int _cntDisplayedAlerts;
    
    UIView *_keyView;
    
    UIView *_shadow;
    FXBlurView *_blurView;
    UIButton *_closeButton;
    UIScrollView *_scrllView;
    UIPageControl *_pgContorll;
}

@end

@implementation TGGemsAlertExecutor

- (void)executeAlerts:(NSArray*)alerts
{
    if(alerts.count == 0)
        return;
    if(_isDisplayingAlerts)
    {
        CGFloat x = _scrllView.frame.size.width * _cntDisplayedAlerts;
        for(id alertObject in alerts)
        {
            GemsAlertViewBase *v = [(GemsAlert *)alertObject alertView];
            v.frame = CGRectMake(x, 0, _scrllView.frame.size.width, _scrllView.frame.size.height);
            v.backgroundColor = [UIColor clearColor];
            v.closeBlock = ^{
                [self closeAlerts];
            };
            [_scrllView addSubview:v];
            x += _scrllView.frame.size.width;
        }
        _cntDisplayedAlerts += alerts.count;
        _pgContorll.numberOfPages = _cntDisplayedAlerts;
        _scrllView.contentSize = CGSizeMake(x, _scrllView.frame.size.height);
        [[GemsAlertCenter sharedInstance] markAlertsAsRead:alerts];
        return;
    }
    
    _keyView = [UIApplication sharedApplication].keyWindow;
    
    // dark bg
    _shadow = [[UIView alloc] initWithFrame:_keyView.frame];
    _shadow.backgroundColor = [UIColor blackColor];
    _shadow.alpha = 0.7f;
    [_keyView addSubview:_shadow];
    
    _blurView = [[FXBlurView alloc] initWithFrame:_keyView.frame];
    _blurView.dynamic = NO;
    _blurView.blurRadius = 10.0f;
    _blurView.tintColor = [UIColor blackColor];
    [_keyView addSubview:_blurView];
    
    _scrllView = [[UIScrollView alloc] init];
    _scrllView.frame = _keyView.frame;
    _scrllView.pagingEnabled = YES;
    _scrllView.delegate = self;
    CGFloat x = 0;
    for(id alertObject in alerts)
    {
        GemsAlertViewBase *v = [(GemsAlert *)alertObject alertView];
        v.frame = CGRectMake(x, 0, _scrllView.frame.size.width, _scrllView.frame.size.height);
        v.backgroundColor = [UIColor clearColor];
        v.closeBlock = ^{
            [self closeAlerts];
        };
        [_scrllView addSubview:v];
        x += _scrllView.frame.size.width;
    }
    _cntDisplayedAlerts = alerts.count;
    _scrllView.contentSize = CGSizeMake(x, _scrllView.frame.size.height);
    [_keyView addSubview:_scrllView];
    
    // page controll
    _pgContorll = [[UIPageControl alloc] init];
    _pgContorll.frame = CGRectMake(0, _keyView.frame.size.height - 25, _keyView.frame.size.width, 20);
    _pgContorll.currentPageIndicatorTintColor = [UIColor whiteColor];
    [_pgContorll setCurrentPage:0];
    _pgContorll.userInteractionEnabled = NO;
    _pgContorll.numberOfPages = alerts.count;
    [_keyView addSubview:_pgContorll];
    
    // close button
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.frame = CGRectMake(10, 10, 50, 50);
    [_closeButton setTitle:@"X" forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeAlerts) forControlEvents:UIControlEventTouchUpInside];
    [_keyView addSubview:_closeButton];
    
    _isDisplayingAlerts = YES;
    
    [[GemsAlertCenter sharedInstance] markAlertsAsRead:alerts];
}

- (void)closeAlerts
{
    [_scrllView removeFromSuperview];
    [_shadow removeFromSuperview];
    [_blurView removeFromSuperview];
    [_closeButton removeFromSuperview];
    [_pgContorll removeFromSuperview];
    _scrllView = nil;
    _shadow = nil;
    _blurView = nil;
    _closeButton = nil;
    _pgContorll = nil;
    
    _isDisplayingAlerts = NO;
    _cntDisplayedAlerts = 0;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int width = scrollView.frame.size.width;
    float xPos = scrollView.contentOffset.x+10;
    _pgContorll.currentPage = (int)xPos/width;
}

@end
