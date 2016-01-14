//
//  CurrencyItem.m
//  GetGems
//
//  Created by alon muroch on 5/12/15.
//
//

#import "CurrencyItem.h"

@interface CurrencyItem() {
    NSString *_name, *_desc;
    UIImage *_icon;
    BOOL _isChecked;
    SEL _action;
}
@end

@implementation CurrencyItem

- (instancetype)initWithCurrencyName:(NSString *)name desciption:(NSString*)desc icon:(UIImage*)icon action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        _name = name;
        _desc = desc;
        _icon = icon;
        _action = action;
        self.deselectAutomatically = true;
    }
    return self;
}

- (Class)itemViewClass
{
    return [CurrencyItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44.0f);
}

- (void)bindView:(CurrencyItemView *)view
{
    [super bindView:view];
    
    view.alignToRight = YES;
    
    [view.lblDesc setText:_desc];
    [view.lblName setText:_name];
    [view setIsChecked:_isChecked];
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

- (void)setIsChecked:(bool)isChecked
{
    _isChecked = isChecked;
    
    if ([self boundView] != nil)
        [(TGCheckCollectionItemView *)[self boundView] setIsChecked:_isChecked];
}

- (NSString*)getCurrencyCode
{
    return [_name lowercaseString];
}

@end
