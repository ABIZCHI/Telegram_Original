//
//  FeatureController.h
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "TGViewController.h"
#import "FeaturedCell.h"

// GemsUI
#import <GemsUI/AppStoreBuyButton.h>

@interface FeatureController : TGViewController

@property (strong, nonatomic) IBOutlet UIView *imgBackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIButton *lblDetails;
@property (strong, nonatomic) IBOutlet AppStoreBuyButton *btnBuyView;
@property (strong, nonatomic) IBOutlet UIView *outerView;
@property (strong, nonatomic) IBOutlet UIButton *btnTermsAndConditions;
@property (strong, nonatomic) IBOutlet UITextView *txv;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblDetailsHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topContainerTopConstraint;

- (void)setupWithData:(StoreItemData*)data;

@end
