//
//  GemsLoggedToFacebookView.m
//  GetGems
//
//  Created by alon muroch on 7/22/15.
//
//

#import "GemsLoggedToFacebookView.h"
#import "GetGemsChallenges.h"

// GemsUI
#import <GemsUI/UIImage+Loader.h>

// GemsCore
#import <GemsCore/GemsStringUtils.h>
#import <GemsCore/GemsLocalization.h>
#import <GemsCore/GemsCommons.h>

@implementation GemsLoggedToFacebookView

+ (GemsLoggedToFacebookView*)new
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GemsLoggedToFacebookView" owner:self options:nil];
    GemsLoggedToFacebookView *v = (GemsLoggedToFacebookView *)[nib objectAtIndex:0];
    return v;
}

- (void)awakeFromNib
{
    _lblTitle.text = GemsLocalized(@"FBLoginTitle");
    
    _lblDesc.text = _R(GemsLocalized(@"FBLoginDesc"), @"%1$s", [@(kGemsRewardFbLogin) stringValue]);
    _lblCallForAction.text = GemsLocalized(@"FBLoginInviteFriends");
    
    _btnInvite.layer.borderColor = [[UIColor whiteColor] CGColor];
    _btnInvite.layer.borderWidth = 1.0f;
    _btnInvite.layer.cornerRadius = 10.0f;
    _btnInvite.text = GemsLocalized(@"InviteFriends");
    _btnInvite.icon = [UIImage Loader_gemsImageWithName:@"invite_icon"];
    _btnInvite.clicked = ^(ButtonWithIcon *btn) {
        if(self.closeBlock)
            self.closeBlock();
        
        [GetGemsChallenges shareAppOnFacebookWithCallback:NilCompletionBlock];
    };
}

@end
