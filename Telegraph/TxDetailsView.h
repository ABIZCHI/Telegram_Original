//
//  TxDetailsView.h
//  GetGems
//
//  Created by alon muroch on 6/25/15.
//
//

#import <UIKit/UIKit.h>
#import "Transaction.h"
#import "TGLetteredAvatarView.h"
#import "TGUser+Telegraph.h"

static CGFloat TxDetailsViewNormalHeight = 210.0f;
static CGFloat TxDetailsViewExtendedHeight = 280.0f;

@interface TxDetailsView : UIView

+ (TxDetailsView*)newWithTransaction:(Transaction*)transaction;

@property (nonatomic, copy) void (^close)();

@property (strong, nonatomic) IBOutlet UIView *bottomContainer;
@property (strong, nonatomic) IBOutlet TGLetteredAvatarView *leftIV;
@property (strong, nonatomic) IBOutlet TGLetteredAvatarView *rightIV;
@property (strong, nonatomic) IBOutlet UIButton *lblLeft;
@property (strong, nonatomic) IBOutlet UIButton *lblRight;
@property (strong, nonatomic) IBOutlet UIImageView *arrowIV;
@property (strong, nonatomic) IBOutlet UILabel *lblReceivedAmount;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;

@property(nonatomic, strong) Transaction *transaction;
@property (nonatomic, assign) BOOL showDetailsView;


@end
