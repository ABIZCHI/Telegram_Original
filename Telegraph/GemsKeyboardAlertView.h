//
//  GemsKeyboardAlertView.h
//  GetGems
//
//  Created by alon muroch on 03/03/2016.
//
//

#import "GemsAlertViewBase.h"

// GemsUI
#import <GemsUI/ButtonWithIcon.h>

@interface GemsKeyboardAlertView : GemsAlertViewBase


@property (weak, nonatomic) IBOutlet UIButton *btnTellMeMore;
@property (weak, nonatomic) IBOutlet UIButton *btnNotNow;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstMsg;
@property (weak, nonatomic) IBOutlet UILabel *lblSecondMsg;

@end
