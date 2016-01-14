//
//  FeaturedAllCell.h
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import <UIKit/UIKit.h>
#import "FeaturedCell.h"
#import "AppStoreBuyButton.h"

@interface FeaturedAllCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDetails;
@property (strong, nonatomic) IBOutlet UIImageView *iv;
@property (strong, nonatomic) IBOutlet AppStoreBuyButton *btnBuyNow;


- (void)bindCell:(StoreItemData*)data;
+ (NSString*)cellIdentifier;
+ (CGFloat)cellHeight;

@end
