/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGVariantCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGVariantCollectionItemView ()
{
    UILabel *_titleLabel;
    UILabel *_variantLabel;
    UIImageView *_disclosureIndicator;
    GEMS_ADDED_PROPERTY UIImageView *_icon;
}

@end

@implementation TGVariantCollectionItemView

GEMS_TG_METHOD_CHANGED
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        [self addSubview:_titleLabel];
        
        _variantLabel = [[UILabel alloc] init];
        _variantLabel.textColor = UIColorRGB(0x929297);
        _variantLabel.backgroundColor = [UIColor clearColor];
        _variantLabel.font = TGSystemFontOfSize(17);
        [self addSubview:_variantLabel];
        
        _disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernListsDisclosureIndicator.png"]];
        [self addSubview:_disclosureIndicator];
        
        _icon = [[UIImageView alloc] init];
        [self addSubview:_icon];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    [self setNeedsLayout];
}

GEMS_ADDED_METHOD
- (void)setIcon:(UIImage*)iconImg
{
    if(iconImg) {
        [_icon setImage:iconImg];
        [self setNeedsLayout];
    }
    else {
        _icon = nil;
    }
}

- (void)setVariant:(NSString *)variant
{
    _variantLabel.text = variant;
    [self setNeedsLayout];
}

GEMS_TG_METHOD_CHANGED
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGSize titleSize = [_titleLabel sizeThatFits:CGSizeMake(bounds.size.width, CGFLOAT_MAX)];
    CGSize variantSize = [_variantLabel sizeThatFits:CGSizeMake(bounds.size.width, CGFLOAT_MAX)];
    
    _disclosureIndicator.frame = CGRectMake(bounds.size.width - _disclosureIndicator.frame.size.width - 15, floorf((bounds.size.height - _disclosureIndicator.frame.size.height) / 2), _disclosureIndicator.frame.size.width, _disclosureIndicator.frame.size.height);
    
    CGFloat startingX = _icon? 40.0f:15.0f;
    CGFloat indicatorSpacing = 10.0f;
    CGFloat labelSpacing = 8.0f;
    CGFloat availableWidth = _disclosureIndicator.frame.origin.x - startingX - indicatorSpacing;
    
    CGFloat titleY =  CGFloor((bounds.size.height - titleSize.height) / 2.0f) + TGRetinaPixel;
    CGFloat variantY =  CGFloor((bounds.size.height - variantSize.height) / 2.0f) + TGRetinaPixel;
    
    if (titleSize.width + labelSpacing + variantSize.width <= availableWidth)
    {
        _titleLabel.frame = CGRectMake(startingX, titleY, titleSize.width, titleSize.height);
        _variantLabel.frame = CGRectMake(startingX + availableWidth - variantSize.width, variantY, variantSize.width, variantSize.height);
    }
    else if (titleSize.width > variantSize.width)
    {
        CGFloat titleWidth = CGFloor(availableWidth * 2.0f / 3.0f) - labelSpacing;
        _titleLabel.frame = CGRectMake(startingX, titleY, titleWidth, titleSize.height);
        CGFloat variantWidth = MIN(variantSize.width, availableWidth - titleWidth - labelSpacing);
        _variantLabel.frame = CGRectMake(startingX + availableWidth - variantWidth, variantY, variantWidth, variantSize.height);
    }
    else
    {
        CGFloat variantWidth = CGFloor(availableWidth / 2.0f) - labelSpacing;
        _variantLabel.frame = CGRectMake(startingX + availableWidth - variantWidth, variantY, variantWidth, variantSize.height);
        CGFloat titleWidth = MIN(titleSize.width, availableWidth - variantWidth - labelSpacing);
        _titleLabel.frame = CGRectMake(startingX, titleY, titleWidth, titleSize.height);
    }
    
    if(_icon)
        _icon.frame = CGRectMake(10, floorf((bounds.size.height - 15) / 2), 15, 15);
}

@end
