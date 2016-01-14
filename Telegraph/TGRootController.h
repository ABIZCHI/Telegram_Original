#import "TGViewController.h"

#import <SSignalKit/SSignalKit.h>

#import "TGNavigationController.h"

@class TGDialogListController;
@class TGContactsController;
@class TGAccountSettingsController;
@class TGMainTabsController;

@interface TGRootController : TGViewController

@property (nonatomic, strong) TGMainTabsController *mainTabsController;
@property (nonatomic, strong) TGDialogListController *dialogListController;
@property (nonatomic, strong) TGContactsController *contactsController;
@property (nonatomic, strong) TGAccountSettingsController *accountSettingsController;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGNavigationController *masterNavigationController;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGNavigationController *detailNavigationController;

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
