//
//  IntroController.m
//  GetGems
//
//  Created by alon muroch on 06/03/2016.
//
//

#import "IntroController.h"

@interface IntroController() <UIScrollViewDelegate> {
    UIImageView *_firstView, *_secondView, *_thirdView;
}

@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIPageControl *pgControll;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation IntroController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *img1 = [UIImage imageNamed:@"intro_logo"];
    _firstView = [[UIImageView alloc] init];
    _firstView.image = img1;
    _firstView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImage *img2 = [UIImage imageNamed:@"intro_social"];
    _secondView = [[UIImageView alloc] init];
    _secondView.image = img2;
    _secondView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImage *img3 = [UIImage imageNamed:@"intro_txs"];
    _thirdView = [[UIImageView alloc] init];
    _thirdView.image = img3;
    _thirdView.contentMode = UIViewContentModeScaleAspectFit;
    
    [_scrollView addSubview:_firstView];
    [_scrollView addSubview:_secondView];
    [_scrollView addSubview:_thirdView];
    
    _pgControll.currentPage = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GemsAnalytics track:KbIntroViewed args:nil];
    [GemsAnalytics track:KbIntroPage args:@{@"page" : @( _pgControll.currentPage)}];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _firstView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    _secondView.frame = CGRectMake(_scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    _thirdView.frame = CGRectMake(_scrollView.frame.size.width * 2, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3, 0);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    [GemsAnalytics track:KbIntroAction args:@{@"type" : @"continue"}];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    double pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    _pgControll.currentPage = (int)pageNumber;
    
    [GemsAnalytics track:KbIntroPage args:@{@"page" : @( _pgControll.currentPage)}];
}

@end
