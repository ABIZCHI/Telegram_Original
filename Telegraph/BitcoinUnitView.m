//
//  BitcionUnitCell.m
//  GetGems
//
//  Created by alon muroch on 6/17/15.
//
//

#import "BitcoinUnitView.h"
#import "TGFont.h"


@implementation BitcoinUnitView

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
    
    CGFloat leftPadding = 20.0f, rightPadding = 50.0f, iconWidth = 30.0f, codeWidth = 50.0f, descWidth;
    descWidth = bounds.size.width - leftPadding - iconWidth - 10 - codeWidth - 10 - rightPadding;
    
    _lblName.frame = CGRectMake(leftPadding, floorf((bounds.size.height - 26) / 2), descWidth, 26);
}


@end
