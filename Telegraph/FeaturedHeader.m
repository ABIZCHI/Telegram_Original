//
//  FeaturedHeader.m
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "FeaturedHeader.h"
#import "TGCommon.h"

@interface FeaturedHeader()
{
    UIButton *_btnSeeMore;
}

@end

@implementation FeaturedHeader

- (instancetype)init
{
    self = [super init];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        
        _lblTitle = [[UILabel alloc] init];
        _lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        _lblTitle.textColor = [UIColor blackColor];
        [self addSubview:_lblTitle];
        
        
        _btnSeeMore = [[UIButton alloc] init];
        [_btnSeeMore addTarget:self action:@selector(seeMore) forControlEvents:UIControlEventTouchUpInside];
        _btnSeeMore.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
        _btnSeeMore.titleLabel.textColor = [UIColor grayColor];
        [_btnSeeMore setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnSeeMore setTitle:@"See All>" forState:UIControlStateNormal];
        [self addSubview:_btnSeeMore];
        
        _seperatorView = [[UIView alloc] init];
        _seperatorView.backgroundColor = UIColorRGB(0xe1e0e0);
        [self addSubview:_seperatorView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _lblTitle.frame = CGRectMake(10, 0, self.frame.size.width - 100, self.frame.size.height);
    _btnSeeMore.frame = CGRectMake(self.frame.size.width - 80, 0, 50, self.frame.size.height);
    _seperatorView.frame = CGRectMake(10, 0, self.frame.size.width - 10, 0.5);
}

- (void)setSeeMoreBlock:(void (^)())seeMoreBlock
{
    _seeMoreBlock = seeMoreBlock;
    
    if(!_seeMoreBlock)
        _btnSeeMore.hidden = YES;
}

- (void)seeMore
{
    if(_seeMoreBlock)
        _seeMoreBlock();
}

@end
