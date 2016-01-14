/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import "ActionStage.h"

#import "TGNavigationController.h"
#import "TGModernButton.h"
#import "TGProgressWindow.h"

@interface TGLoginCodeController : TGViewController <ASWatcher, TGNavigationControllerItem>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *phoneCodeHash;
@property (nonatomic, strong) NSString *phoneCode;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) UIView *grayBackground;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) UILabel *titleLabel;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGModernButton *didNotReceiveCodeButton;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGProgressWindow *progressWindow;
GEMS_PROPERTY_EXTERN @property (nonatomic) int currentActionIndex;
GEMS_PROPERTY_EXTERN @property (nonatomic) bool inProgress;
GEMS_PROPERTY_EXTERN @property (nonatomic) bool messageSentToTelegram;

- (id)initWithShowKeyboard:(bool)showKeyboard phoneNumber:(NSString *)phoneNumber phoneCodeHash:(NSString *)phoneCodeHash phoneTimeout:(NSTimeInterval)phoneTimeout messageSentToTelegram:(bool)messageSentToTelegram;

- (void)applyCode:(NSString *)code;


GEMS_METHOD_EXTERN - (void)didNotReceiveCodeButtonPressed;
GEMS_METHOD_EXTERN - (void)pushControllerRemovingSelf:(UIViewController *)controller;

@end
