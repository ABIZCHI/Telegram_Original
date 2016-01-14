//
//  GemsPassphraseRemainderView.h
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import "GemsAlertViewBase.h"
#import "ButtonWithIcon.h"

@interface GemsPassphraseRemainderView : GemsAlertViewBase
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblCongrats;
@property (strong, nonatomic) IBOutlet UILabel *lblExplanation;
@property (strong, nonatomic) IBOutlet ButtonWithIcon *btnShowPassphrase;

@end
