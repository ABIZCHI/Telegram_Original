//
//  SquareImageCell.m
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "SquareImageCell.h"
#import "FeaturedCell.h"
#import "GetGemsCell.h"
#import <QuartzCore/QuartzCore.h>

//GemsUI
#import <UIImage+Loader.h>
#import <GemsAppearance.h>

@interface SquareImageCell()
{    
    UIView *_doneOverlay, *_doneContainer;
    DoneCircleView *_doneCircle;
}

@end

@implementation SquareImageCell

- (void)awakeFromNib {
    _iv.layer.cornerRadius = 15.0f;
    _iv.layer.masksToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _doneOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _iv.frame.size.width, _iv.frame.size.height)];
    _doneOverlay.backgroundColor = [UIColor whiteColor];
    _doneOverlay.alpha = 0.0f;
    
    _doneContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _iv.frame.size.width, _iv.frame.size.height)];
    _doneContainer.backgroundColor = [UIColor clearColor];
    _doneCircle = [[DoneCircleView alloc] init];
    _doneCircle.frame = CGRectMake(_doneContainer.center.x - 22, _doneContainer.center.y - 14, 38, 38);
    [_doneContainer addSubview:_doneCircle];
    [_doneOverlay addSubview:_doneContainer];
    
    [_iv addSubview:_doneOverlay];
}

+ (CGFloat)cellWidth
{
    return 110.0f;
}

+ (NSString*)cellIdentifier
{
    return @"SquareImageCell";
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    _doneCircle.color = _titleColor;
}

- (void)bindCell:(id)data
{
    _data = data;
    
    if([_data isMemberOfClass:[StoreItemData class]])
    {
        StoreItemData *_d = (StoreItemData*)_data;
        
        [_iv sd_setImageWithURL:[NSURL URLWithString:_d.iconURL] placeholderImage:[UIImage Loader_gemsImageWithName:@"icon_placeholder"]];
        NSString *details = [NSString stringWithFormat:@"%@\n%@ Gems", _d.categoryStr, formatDoubleToStringWithDecimalPrecision([[_d.price currency_gillosToGems] doubleValue], 3)];
        
        [UIView performWithoutAnimation:^{
            [_lbl setAttributedTitle:[self attribuitedStringWithTitle:_d.title details:details] forState:UIControlStateNormal];
        }];
    }
    
    if([_data isMemberOfClass:[GetGemsCellData class]])
    {
        GetGemsCellData *_d = (GetGemsCellData*)_data;
        
        [_iv sd_setImageWithURL:[NSURL URLWithString:_d.iconURL] placeholderImage:[UIImage Loader_gemsImageWithName:@"icon_placeholder"]];
        
        NSString *details;
        if(_d.reward) {
            details = [NSString stringWithFormat:@"%@ Gems", formatDoubleToStringWithDecimalPrecision([[_d.reward currency_gillosToGems] doubleValue], 3)];
        }
        else {
            details = @"";
        }
        [UIView performWithoutAnimation:^{
            [_lbl setAttributedTitle:[self attribuitedStringWithTitle:_d.title details:details] forState:UIControlStateNormal];
        }];
        
        if(_d.completed) {
            
            
            if(_d.didAnimateCompletion)
            {
                _doneOverlay.alpha = 0.9f;
                [_doneCircle setShow:YES animated:NO];
            }
            else
                [self coverWithDoneOverlay];
        }
        else
            _doneOverlay.alpha = 0.0f;
    }
    _lbl.titleLabel.numberOfLines = 0;
}

- (NSAttributedString*)attribuitedStringWithTitle:(NSString*)title details:(NSString*)details
{    
    
    
    NSMutableString *cleanText = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", title, details]];
    
    NSMutableAttributedString *attribuitedText = [[NSMutableAttributedString alloc]initWithString:cleanText];
    
    // title
    NSDictionary *titleAtt = [NSDictionary dictionaryWithObjectsAndKeys:
                                      _titleColor, NSForegroundColorAttributeName,
                                      nil];
    NSRange r = [cleanText rangeOfString:title];
    [attribuitedText addAttributes:titleAtt range:r];
    
    // details
    NSDictionary *detailsAtt = [NSDictionary dictionaryWithObjectsAndKeys:
                                _detailsColor, NSForegroundColorAttributeName,
                                nil];
    r = [cleanText rangeOfString:details];
    [attribuitedText addAttributes:detailsAtt range:r];
    
    return attribuitedText;

}

- (void)coverWithDoneOverlay
{
    [UIView animateWithDuration:0.3f animations:^{
        _doneOverlay.alpha = 0.9f;
    } completion:^(BOOL finished) {
        ((GetGemsCellData*)_data).didAnimateCompletion = YES;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_doneCircle setShow:YES animated:YES];
    });
}

@end
