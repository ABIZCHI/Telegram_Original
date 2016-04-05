/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGSwitchCollectionItemView.h"

#import "TGFont.h"

@interface TGSwitchCollectionItemView ()
{
    UILabel *_titleLabel;
    UISwitch *_switchView;
    UIImageView *_icon;
}

@end

@implementation TGSwitchCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {   
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TGSystemFontOfSize(17);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
        
        _switchView = [[UISwitch alloc] init];
        [_switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_switchView];
        
        _icon = [[UIImageView alloc] init];
        [self addSubview:_icon];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setIsOn:(bool)isOn animated:(bool)animated
{
    [_switchView setOn:isOn animated:animated];
}

GEMS_ADDED_METHOD
- (void)setIcon:(UIImage*)iconImg
{
    if(iconImg) {
        [_icon setImage:iconImg];
        [self setNeedsLayout];
    }
    else {
        _icon.image = nil;
    }
}

- (void)switchValueChanged
{
    id<TGSwitchCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(switchCollectionItemViewChangedValue:isOn:)])
        [delegate switchCollectionItemViewChangedValue:self isOn:_switchView.on];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGSize switchSize = _switchView.bounds.size;
    CGFloat lblPadding = _icon.image? 40.0f:15.0f;
    
    _switchView.frame = CGRectMake(bounds.size.width - switchSize.width - lblPadding, 6.0f, switchSize.width, switchSize.height);
    
    _titleLabel.frame = CGRectMake(lblPadding, CGFloor((bounds.size.height - 26.0f) / 2.0f), bounds.size.width - 15.0f - 4.0f - switchSize.width - 6.0f, 26.0f);
    
    if(_icon.image)
        _icon.frame = CGRectMake(10, CGFloor((bounds.size.height - 15) / 2.f), 15, 15);

}

@end
