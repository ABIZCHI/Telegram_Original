//
//  GemsInviterRewardView.h
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import <UIKit/UIKit.h>
#import "GemsAlertViewBase.h"
#import "TGLetteredAvatarView.h"
#import "ButtonWithIcon.h"

@interface GemsInviterRewardView : GemsAlertViewBase

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblExplanation;
@property (strong, nonatomic) IBOutlet UIView *avatarViewContainer;
@property (strong, nonatomic) IBOutlet TGLetteredAvatarView *iv;
@property (strong, nonatomic) IBOutlet UILabel *lblAmountEarned;

@property (strong, nonatomic) IBOutlet ButtonWithIcon *viewBtnMessage;

@property (strong, nonatomic) IBOutlet ButtonWithIcon *viewBtnInvite;


@end
