//
//  GemsAirdropView.m
//  GetGems
//
//  Created by alon muroch on 11/2/15.
//
//

#import "GemsAirdropView.h"
#import "SocialSharerHelper.h"

@implementation GemsAirdropView

+ (GemsAirdropView*)new
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GemsAirdropView" owner:self options:nil];
    GemsAirdropView *v = (GemsAirdropView *)[nib objectAtIndex:0];
    return v;
}

- (void)awakeFromNib
{
    _lblTitle.text = GemsLocalized(@"MoreAirdropTitle");
    _lbl1.text = GemsLocalized(@"MoreAirdopText");
    _lbl2.text = GemsLocalized(@"MoreAirdropInviteMore");
    
    _btn.layer.borderColor = [[UIColor whiteColor] CGColor];
    _btn.layer.borderWidth = 1.0f;
    _btn.layer.cornerRadius = 10.0f;
    _btn.text = GemsLocalized(@"GemsInviteMoreButtonText");
    _btn.icon = [UIImage imageNamed:@"invite_icon"];
    _btn.clicked = ^(ButtonWithIcon *btn) {
        if(self.closeBlock)
            self.closeBlock();
        
        SocialSharerHelper *sharerHelper = [[SocialSharerHelper alloc] init];
        [sharerHelper inviteViaSms];
    };
}

@end
