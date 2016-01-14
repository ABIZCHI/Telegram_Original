/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"
#import "TGProgressWindow.h"
#import "ActionStage.h"
#import "TGBackspaceTextField.h"

@interface TGLoginPhoneController : TGViewController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGProgressWindow *progressWindow;
GEMS_PROPERTY_EXTERN @property (nonatomic) int currentActionIndex;
GEMS_PROPERTY_EXTERN @property (nonatomic) bool inProgress;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) UITextField *countryCodeField;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGBackspaceTextField *phoneField;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) UIView *grayBackground;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) UILabel *titleLabel;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) NSString *phoneNumber;

GEMS_METHOD_EXTERN - (void)_commitNextButtonPressed;

- (void)setPhoneNumber:(NSString *)phoneNumber;

@end
