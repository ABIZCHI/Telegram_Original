//
//  ReferralLinkItemView.h
//  GetGems
//
//  Created by alon muroch on 5/10/15.
//
//

#import "TGCollectionItemView.h"

@interface ReferralLinkItemView : TGCollectionItemView
{
    UIImageView *_icon;
}

@property (nonatomic, strong) UILabel *lblLink;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIImageView *icon;

- (void)setLink:(NSString*)link;

@end
