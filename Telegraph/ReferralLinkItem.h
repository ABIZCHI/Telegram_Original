//
//  ReferralLinkItem.h
//  GetGems
//
//  Created by alon muroch on 5/10/15.
//
//

#import "TGCollectionItem.h"
#import "ReferralLinkItemView.h"

@interface ReferralLinkItem : TGCollectionItem

- (instancetype)initWithReferralLink:(NSString*)link icont:(UIImage*)icon action:(SEL)action;
@property (nonatomic) ReferralLinkItemView *view;

@end
