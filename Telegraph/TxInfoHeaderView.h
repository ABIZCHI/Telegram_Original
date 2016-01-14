//
//  ReferralInfoHeaderView.h
//  GetGems
//
//  Created by alon muroch on 6/3/15.
//
//

#import <UIKit/UIKit.h>

@interface TxInfoHeaderView : UIView
@property (strong, nonatomic) IBOutlet UILabel *lblCntReferrals;
@property (strong, nonatomic) IBOutlet UILabel *lblRewards;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *infoViewContainerTopContraint;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIView *infoViewContainer;

- (void)loadInfo;
- (void)hideInfoView;
- (void)moveInfoViewContainerToPlace:(CGFloat)percent;

@end
