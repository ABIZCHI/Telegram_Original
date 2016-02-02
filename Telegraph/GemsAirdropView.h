//
//  GemsAirdropView.h
//  GetGems
//
//  Created by alon muroch on 11/2/15.
//
//

#import "GemsAlertViewBase.h"

// GemsUI
#import <GemsUI/UIImage+Loader.h>
#import <GemsUI/ButtonWithIcon.h>

@interface GemsAirdropView : GemsAlertViewBase

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lbl1;
@property (strong, nonatomic) IBOutlet UILabel *lbl2;
@property (strong, nonatomic) IBOutlet ButtonWithIcon *btn;


@end
