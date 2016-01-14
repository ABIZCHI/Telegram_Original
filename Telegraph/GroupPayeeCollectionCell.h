//
//  GroupPayeeCollectionCell.h
//  GetGems
//
//  Created by alon muroch on 7/14/15.
//
//

#import <UIKit/UIKit.h>
#import "PaymentRequest.h"
#import "TGLetteredAvatarView.h"

static NSString *GroupPayeeCollectionCellIdentifier = @"GroupPayeeCollectionCell";

@interface GroupPayeeCollectionCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet TGLetteredAvatarView *iv;
@property (strong, nonatomic) IBOutlet UIButton *lbl;
@property (strong, nonatomic) IBOutlet UIView *imgViewContainer;

- (void)bindCellForPaymentRequest:(PaymentRequest*)pr;

@end
