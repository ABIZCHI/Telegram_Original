//
//  ReferralLinkItemView.m
//  GetGems
//
//  Created by alon muroch on 5/10/15.
//
//

#import "ReferralLinkItemView.h"
#import "TGFont.h"

@implementation ReferralLinkItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _title = [[UILabel alloc] init];
        _title.font = TGSystemFontOfSize(17);
        _title.text = GemsLocalized(@"GemsReferralLink");
        [self addSubview:_title];
        
        _lblLink = [[UILabel alloc] init];
        _lblLink.font = TGSystemFontOfSize(12);
        _lblLink.text = GemsLocalized(@"GemsEarned");
        _lblLink.textColor = [UIColor lightGrayColor];
        [self addSubview:_lblLink];

        _icon = [[UIImageView alloc] init];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_icon];
    }
    return self;
}

- (void)setLink:(NSString*)link
{
    _lblLink.text = link;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat startingX = (_icon.image != nil) ? 59.0f : 15.0f;
    
    CGRect r = CGRectMake(startingX, 0, self.frame.size.width, self.frame.size.height / 2);
    _title.frame = r;
    
    CGRect r2 = CGRectMake(startingX, CGFloor(self.frame.size.height - r.size.height * 1.1), self.frame.size.width, self.frame.size.height / 2);
    _lblLink.frame = r2;
    
    if(_icon)
    {
        _icon.frame = CGRectMake(15, CGFloor((self.frame.size.height - 29) / 2), 29, 29);
    }
    
}

@end
