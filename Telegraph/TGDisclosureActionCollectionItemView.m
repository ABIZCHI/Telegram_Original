#import "TGDisclosureActionCollectionItemView.h"

#import "TGFont.h"

@interface TGDisclosureActionCollectionItemView ()
{
    UILabel *_titleLabel;
    UIImageView *_disclosureIndicator, GEMS_ADDED_PROPERTY *_icon;
    
}

@end

@implementation TGDisclosureActionCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        [self addSubview:_titleLabel];
        
        _disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernListsDisclosureIndicator.png"]];
        [self addSubview:_disclosureIndicator];
        
        _icon = [[UIImageView alloc] init];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_icon];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    
    [self setNeedsLayout];
}

- (void)setIcon:(UIImage*)iconImg {
    if(iconImg) {
        [_icon setImage:iconImg];
        [self setNeedsLayout];
    }
    else {
        _icon.image = nil;
    }
}

GEMS_TG_METHOD_CHANGED
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat lblPadding = _icon.image? 40.0f:15.0f;
    
    _titleLabel.frame = CGRectMake(lblPadding, floorf((bounds.size.height - 26) / 2), bounds.size.width - 40 - 40, 26);
    _disclosureIndicator.frame = CGRectMake(bounds.size.width- _disclosureIndicator.frame.size.width - 15, floorf((bounds.size.height - _disclosureIndicator.frame.size.height) / 2), _disclosureIndicator.frame.size.width, _disclosureIndicator.frame.size.height);
    
    if(_icon.image)
        _icon.frame = CGRectMake(10, floorf((bounds.size.height - 15) / 2), 15, 15);
}

@end
