//
//  UILabel+Utils.m
//  GetGems
//
//  Created by alon muroch on 6/25/15.
//
//

#import "UILabel+Utils.h"

@implementation UILabel (Utils)

- (void)resizeFontForLabelForSize:(CGSize)size text:(NSString*)text
{
    UIFont *font = self.font;
    
    float lblWidth = size.width;
    float lblHeight = size.height;
    
    CGFloat fontSize = [font pointSize];
    UIFont *newFont = font;
    
    CGFloat height = [text sizeWithFont:font constrainedToSize:CGSizeMake(lblWidth,MAXFLOAT) lineBreakMode:self.lineBreakMode].height;
    
    //Reduce font size while too large, break if no height (empty string)
    while (height > lblHeight && height != 0) {
        fontSize--;
        newFont = [UIFont fontWithName:font.fontName size:fontSize];
        height = [text sizeWithFont:newFont constrainedToSize:CGSizeMake(lblWidth,MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;
    };
    
    self.font = newFont;
    
    [self setNeedsLayout];
}

@end
