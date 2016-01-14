//
//  LoadMoreTableViewCell.m
//  GetGems
//
//  Created by alon muroch on 6/23/15.
//
//

#import "LoadMoreTableViewCell.h"

@implementation LoadMoreTableViewCell

- (void)awakeFromNib {
    [_activityIndicator startAnimating];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


@end
