//
//  BannersTableHeaderView.h
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import <UIKit/UIKit.h>
#import "AppStoreCellData.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppStoreCellBase.h"

@interface BannersTableHeaderView : UIView <UIScrollViewDelegate>

+ (CGFloat)height;
- (void)bind:(id)data;
- (void)freezeMovmentForOffset:(CGFloat)offset;

@property(nonatomic, strong) id<AppStoreCellDelegate> delegate;

@end
