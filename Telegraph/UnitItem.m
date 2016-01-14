//
//  UnitItem.m
//  GetGems
//
//  Created by alon muroch on 6/17/15.
//
//

#import "UnitItem.h"
#import "BitcoinUnitView.h"

@interface UnitItem() {
    NSString *_name;
    BOOL _isChecked;
    SEL _action;
}
@end

@implementation UnitItem

- (instancetype)initWithUnitName:(NSString*)name  action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        _name = name;
        _action = action;
        self.deselectAutomatically = true;
    }
    return self;
}

- (void)bindView:(BitcoinUnitView *)view
{
    [super bindView:view];
    
    view.alignToRight = YES;
    view.denomination = _denomination;
    [view.lblName setText:_name];
    [view setIsChecked:_isChecked];
}

- (void)setIsChecked:(bool)isChecked
{
    _isChecked = isChecked;
    
    if ([self boundView] != nil)
        [(TGCheckCollectionItemView *)[self boundView] setIsChecked:_isChecked];
}

- (void)itemSelected:(id)actionTarget
{
    if (_action != NULL && [actionTarget respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([NSStringFromSelector(_action) rangeOfString:@":"].location != NSNotFound)
            [actionTarget performSelector:_action withObject:self];
        else
            [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

- (Class)itemViewClass
{
    return [BitcoinUnitView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44.0f);
}

@end
