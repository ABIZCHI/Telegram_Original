//
//  CurrencyItemView.h
//  GetGems
//
//  Created by alon muroch on 5/12/15.
//
//

#import "TGCheckCollectionItemView.h"
#import "TGLetteredAvatarView.h"

@interface CurrencyItemView : TGCheckCollectionItemView

@property(nonatomic, strong) UILabel *lblDesc;
@property(nonatomic, strong) UILabel *lblName;

@end
