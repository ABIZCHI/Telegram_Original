//
//  FeaturedHeader.h
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "AppStoreHeaderFooterViewBase.h"

@interface FeaturedHeader : AppStoreHeaderFooterViewBase

@property (nonatomic, copy) void (^seeMoreBlock)();
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIView *seperatorView;

@end
