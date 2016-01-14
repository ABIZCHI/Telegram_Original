//
//  AppStoreCellBase.h
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import <UIKit/UIKit.h>
#import "AppStoreCellData.h"
#import <SDWebImage/UIImageView+WebCache.h>

@class AppStoreCellBase;
@protocol AppStoreCellDelegate

- (void)didSelectCell:(AppStoreCellBase*)cell inContainingCell:(AppStoreCellBase*)containingCell data:(AppStoreCellData*)data;

@end

@interface AppStoreCellBase : UITableViewCell

@property(strong, nonatomic) NSIndexPath *indexPath;

+ (CGFloat)cellHeight;
+ (CGFloat)cellWidth;
+ (NSString*)cellIdentifier;
- (void)bindCell:(id)data;

@end
