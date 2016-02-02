//
//  GemsLoggedToFacebookView.h
//  GetGems
//
//  Created by alon muroch on 7/22/15.
//
//

#import "GemsAlertViewBase.h"

// GemsUI
#import <GemsUI/ButtonWithIcon.h>

@interface GemsLoggedToFacebookView : GemsAlertViewBase

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDesc;
@property (strong, nonatomic) IBOutlet UILabel *lblCallForAction;
@property (strong, nonatomic) IBOutlet ButtonWithIcon *btnInvite;
@end
