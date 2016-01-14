//
//  GemsPassphraseRemainderView.m
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import "GemsPassphraseRemainderView.h"
#import "TGGems.h"
#import <UIImage+Loader.h>

// GemsCore
#import <GemsLocalization.h>

@implementation GemsPassphraseRemainderView

+ (GemsPassphraseRemainderView*)new
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GemsPassphraseRemainderView" owner:self options:nil];
    GemsPassphraseRemainderView *v = (GemsPassphraseRemainderView *)[nib objectAtIndex:0];
    return v;
}

- (void)awakeFromNib
{
    _lblTitle.text = GemsLocalized(@"FirstBitcoinTitle");
    _lblCongrats.text = GemsLocalized(@"FirstBitcoinCongrats");
    _lblExplanation.text = GemsLocalized(@"FirstBitcoinDesc");
    
    _btnShowPassphrase.layer.borderColor = [[UIColor whiteColor] CGColor];
    _btnShowPassphrase.layer.borderWidth = 1.0f;
    _btnShowPassphrase.layer.cornerRadius = 10.0f;
    _btnShowPassphrase.text = GemsLocalized(@"GemsRecoverPassphraseDialogAction");
    _btnShowPassphrase.icon = [UIImage imageNamed:@"passphrase_lock_icon"];
    _btnShowPassphrase.clicked = ^(ButtonWithIcon *btn) {
        if(self.closeBlock)
            self.closeBlock();
        [GEMS showPassphraseRecoveryView];
    };
}

@end
