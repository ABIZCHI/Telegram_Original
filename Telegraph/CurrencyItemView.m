//
//  CurrencyItemView.m
//  GetGems
//
//  Created by alon muroch on 5/12/15.
//
//

#import "CurrencyItemView.h"
#import "TGFont.h"

@implementation CurrencyItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.separatorInset = 44.0f;
        
        for(UIView *v in self.subviews)
            if([v isKindOfClass:[UILabel class]]) {
                [v removeFromSuperview];
            }
        
        _lblDesc = [[UILabel alloc] init];
        _lblDesc.textColor = [UIColor blackColor];
        _lblDesc.backgroundColor = [UIColor clearColor];
        _lblDesc.font = TGSystemFontOfSize(17);
        [self addSubview:_lblDesc];
        
        _lblName = [[UILabel alloc] init];
        _lblName.textColor = [UIColor blackColor];
        _lblName.backgroundColor = [UIColor clearColor];
        _lblName.textColor = [UIColor lightGrayColor];
        _lblName.font = TGSystemFontOfSize(17);
        [self addSubview:_lblName];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat leftPadding = 20.0f, rightPadding = 50.0f, codeWidth = 50.0f, descWidth;
    descWidth = bounds.size.width - leftPadding - 10 - codeWidth - 10 - rightPadding;
    
    _lblDesc.frame = CGRectMake(leftPadding, floorf((bounds.size.height - 26) / 2), descWidth, 26);
    _lblName.frame = CGRectMake(_lblDesc.frame.origin.x + _lblDesc.frame.size.width + 10, floorf((bounds.size.height - 26) / 2), codeWidth, 26);
}


@end
