//
//  GemsAttachmentSheetImageItemView.h
//  GetGems
//
//  Created by alon muroch on 5/4/15.
//
//

#import "TGAttachmentSheetItemView.h"
#import "TGModernButton.h"

@interface GemsAttachmentSheetImageItemView : TGAttachmentSheetItemView
{
    UIImage *_img;
    TGModernButton *_btn;
}

- (instancetype)initWithImage:(UIImage *)img pressed:(void (^)())pressed;
@property (nonatomic, copy) void (^pressed)();

@end
