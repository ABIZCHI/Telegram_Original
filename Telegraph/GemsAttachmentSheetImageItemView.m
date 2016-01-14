//
//  GemsAttachmentSheetImageItemView.m
//  GetGems
//
//  Created by alon muroch on 5/4/15.
//
//

#import "GemsAttachmentSheetImageItemView.h"
#import "TGFont.h"
#import "TGImageUtils.h"

@implementation GemsAttachmentSheetImageItemView

- (instancetype)initWithImage:(UIImage *)img pressed:(void (^)())pressed
{
    self = [super init];
    if(self) {
        _img = img;
        
        _pressed = pressed;
        
        _btn = [[TGModernButton alloc] init];
        [_btn setBackgroundColor:[UIColor clearColor]];
        [_btn.imageView setContentMode:UIViewContentModeScaleToFill];
        [_btn setImage:_img forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(btnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btn];
        
        [self setShowsBottomSeparator:NO];
        [self setShowsTopSeparator:NO];
    }
    return self;
}

- (void)btnPressed
{
    if(_pressed)
        _pressed();
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _btn.frame = CGRectInset(self.bounds, 15, 15);
}

@end
