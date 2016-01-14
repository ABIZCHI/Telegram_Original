//
//  LoadMoreTableViewCell.h
//  GetGems
//
//  Created by alon muroch on 6/23/15.
//
//

#import <UIKit/UIKit.h>

static NSString *LoadMoreTableViewCellIdentifier = @"LoadMoreTableViewCellIdentifier";
static CGFloat LoadMoreTableViewCellHeight = 44.0f;

@interface LoadMoreTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
