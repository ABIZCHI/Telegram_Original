#import "TGViewController.h"

#import <SSignalKit/SSignalKit.h>

#import "GemsWalletViewController.h"
#import "GemsDialogListController.h"

@class TGDialogListController;
@class TGContactsController;
@class TGAccountSettingsController;
@class TGMainTabsController;

@interface TGRootController : TGViewController

@property (nonatomic, strong, readonly) TGMainTabsController *mainTabsController;
@property (nonatomic, strong, readonly) GemsDialogListController *dialogListController;
@property (nonatomic, strong, readonly) TGContactsController *contactsController;
@property (nonatomic, strong) TGAccountSettingsController *accountSettingsController;
GEMS_ADDED_PROPERTY @property(nonatomic, strong) GemsWalletViewController *gemsWalletController;

- (SSignal *)sizeClass;
- (bool)isSplitView;
- (CGRect)applicationBounds;

- (void)pushContentController:(UIViewController *)contentController;
- (void)replaceContentController:(UIViewController *)contentController;
- (void)popToContentController:(UIViewController *)contentController;
- (void)clearContentControllers;
- (NSArray *)viewControllers;

- (void)localizationUpdated;

- (bool)isRTL;

@end
