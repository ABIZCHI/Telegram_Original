//
//  CurrencyItem.h
//  GetGems
//
//  Created by alon muroch on 5/12/15.
//
//

#import "TGCheckCollectionItem.h"
#import "CurrencyItemView.h"
#import "TGLetteredAvatarView.h"

@interface CurrencyItem : TGCheckCollectionItem

- (instancetype)initWithCurrencyName:(NSString *)name desciption:(NSString*)desc icon:(UIImage*)icon action:(SEL)action;
- (void)setIsChecked:(bool)isChecked;
- (NSString*)getCurrencyCode;

@end
