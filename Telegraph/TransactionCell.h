//
//  ReferralCell.h
//  GetGems
//
//  Created by alon muroch on 6/3/15.
//
//

#import <UIKit/UIKit.h>
#import "TGLetteredAvatarView.h"
#import "TGUser+Telegraph.h"
#import "Transaction.h"

static NSString *TransactionCellIdentifier = @"TransactionCellIdentifier";
static CGFloat TransactionCellHeight = 70;

@interface TransactionCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblAmount;
@property (strong, nonatomic) IBOutlet UILabel *lblitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet TGLetteredAvatarView *iv;

- (void)bindCellWithTransaction:(Transaction*)tx;

@end
