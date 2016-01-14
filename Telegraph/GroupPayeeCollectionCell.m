//
//  GroupPayeeCollectionCell.m
//  GetGems
//
//  Created by alon muroch on 7/14/15.
//
//

#import "GroupPayeeCollectionCell.h"
#import "TGUser.h"
#import "TGDatabase.h"

#import <QuartzCore/QuartzCore.h>

// GemsCore
#import <GemsCore/Macros.h>

@implementation GroupPayeeCollectionCell

- (void)awakeFromNib {
    _lbl.titleLabel.numberOfLines = 1;
    _lbl.titleLabel.adjustsFontSizeToFitWidth = YES;
    _lbl.titleLabel.minimumScaleFactor = 0.5f;
    
    _imgViewContainer.layer.cornerRadius = _imgViewContainer.frame.size.width/2;
    
    [_iv setSingleFontSize:17.0f doubleFontSize:17.0f useBoldFont:true];
    _iv.fadeTransition = NO;
}

- (void)bindCellForPaymentRequest:(PaymentRequest*)pr
{
    [UIView setAnimationsEnabled:NO];
    

    TGUser *user = [TGDatabaseInstance() loadUser:pr.receiverTelegramID];
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    [_lbl setAttributedTitle:[self attribuitedStringWithName:name] forState:UIControlStateNormal];

    CGFloat diameter = IS_IPAD ? 45.0f : 37.0f;
    
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
                      CGContextRef context = UIGraphicsGetCurrentContext();
                      
                      //!placeholder
                      CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                      CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                      CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
                      CGContextSetLineWidth(context, 1.0f);
                      CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, diameter - 1.0f, diameter - 1.0f));
                      
                      placeholder = UIGraphicsGetImageFromCurrentImageContext();
                      UIGraphicsEndImageContext();
                  });
    
    if(user.photoUrlSmall)
        [_iv loadImage:user.photoUrlSmall filter:@"circle:40x40" placeholder:placeholder forceFade:true];
    else {
        [_iv loadUserPlaceholderWithSize:CGSizeMake(diameter, diameter) uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
    }
    
    [UIView setAnimationsEnabled:YES];
}

- (NSAttributedString*)attribuitedStringWithName:(NSString*)name
{
    
    
    NSMutableString *cleanText = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@", name]];
    
    NSMutableAttributedString *attribuitedText = [[NSMutableAttributedString alloc]initWithString:cleanText];
    
    // title
    NSDictionary *titleAtt = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor darkGrayColor], NSForegroundColorAttributeName,
                              nil];
    NSRange r = [cleanText rangeOfString:name];
    [attribuitedText addAttributes:titleAtt range:r];
    
    return attribuitedText;
    
}

@end
