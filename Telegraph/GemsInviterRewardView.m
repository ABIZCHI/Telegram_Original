//
//  GemsInviterRewardView.m
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import "GemsInviterRewardView.h"

#import "TGUser.h"
#import "TGDatabase.h"
#import "TGAppDelegate.h"
#import "TGConversation.h"
#import "TGDialogListCompanion.h"
#import "GemsDialogListController.h"

#import "GemsInviteRewardAlert.h"

#import <UIImage+Loader.h>
#import <QuartzCore/QuartzCore.h>
#import <GemsStringUtils.h>

@implementation GemsInviterRewardView

+ (GemsInviterRewardView*)new
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GemsInviterRewardView" owner:self options:nil];
    GemsInviterRewardView *v = (GemsInviterRewardView *)[nib objectAtIndex:0];
    return v;
}

- (void)awakeFromNib
{
    _avatarViewContainer.layer.cornerRadius = _avatarViewContainer.frame.size.height/2;
    _iv.layer.cornerRadius = _avatarViewContainer.frame.size.height/2;
    [_iv setSingleFontSize:32.0f doubleFontSize:32.0f useBoldFont:true];
    _iv.fadeTransition = NO;
    
    _viewBtnInvite.layer.borderColor = [[UIColor whiteColor] CGColor];
    _viewBtnInvite.layer.borderWidth = 1.0f;
    _viewBtnInvite.layer.cornerRadius = 10.0f;
    _viewBtnInvite.text = GemsLocalized(@"InviteFriends");
    _viewBtnInvite.icon = [UIImage imageNamed:@"invite_icon"];
    _viewBtnInvite.clicked = ^(ButtonWithIcon *btn) {
        if(self.closeBlock)
            self.closeBlock();
    };
    
    _viewBtnMessage.layer.borderColor = [[UIColor whiteColor] CGColor];
    _viewBtnMessage.layer.borderWidth = 1.0f;
    _viewBtnMessage.layer.cornerRadius = 10.0f;
    _viewBtnMessage.icon = [UIImage imageNamed:@"message_icon"];
    _viewBtnMessage.clicked = ^(ButtonWithIcon *btn) {
        if(self.closeBlock)
            self.closeBlock();
        
        GemsInviteRewardAlert *alert = (GemsInviteRewardAlert*)self.alertObject;
        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:alert.tgid];
        if(conversation)
        {
            GemsDialogListController *lc = TGAppDelegateInstance.rootController.dialogListController;
            [lc.dialogListCompanion conversationSelected:conversation];
        }
    };
}

- (void)setAlertObject:(id)alertObject
{
    [super setAlertObject:alertObject];
    
    GemsInviteRewardAlert *alert = (GemsInviteRewardAlert*)self.alertObject;
    TGUser *user = [TGDatabaseInstance() loadUser:alert.tgid];
    if(!user) {
        user = [TGUser new];
        user.uid = alert.tgid;
        user.firstName = @"Unknow";
        user.userName = @"Unknow";
    }
    
    [self loadAvatarWithUser:user];
    
    _lblTitle.text = GemsLocalized(@"GemsInviteeSignUpTitle");
    _lblExplanation.text = _R(GemsLocalized(@"GemsInviteeSignUpSummaryText"), @"%1$s", [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName ? user.lastName:@""]);
    
    NSString *amount = formatDoubleToStringWithDecimalPrecision([[@(alert.reward) currency_gillosToGems] doubleValue], sysDecimalPrecisionForUI(_G));
    _lblAmountEarned.text = _R(GemsLocalized(@"GemsInviteeSignUpBonusText"), @"%1$s", amount);
    
    _viewBtnMessage.text = _R(GemsLocalized(@"GemsInviteeSignUpMessageButtonText"), @"%1$s", user.firstName);
}

- (void)loadAvatarWithUser:(TGUser*)user
{
    CGFloat diameter = IS_IPAD ? 45.0f : 37.0f;
    
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
                      CGContextRef context = UIGraphicsGetCurrentContext();
                      
                      //!placeholder
                      CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                      CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
                      CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
                      CGContextSetLineWidth(context, 1.0f);
                      CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, diameter - 1.0f, diameter - 1.0f));
                      
                      placeholder = UIGraphicsGetImageFromCurrentImageContext();
                      UIGraphicsEndImageContext();
                  });
    
    if(user.photoUrlSmall)
        [_iv loadImage:user.photoUrlSmall filter:@"circle:40x40" placeholder:placeholder forceFade:true];
    else {
        [_iv loadUserPlaceholderWithSize:CGSizeMake(diameter, diameter) uid:user.uid firstName:user.firstName lastName:user.lastName placeholder:placeholder];
    }
}

@end
