//
//  GemsRootController.m
//  Telegraph
//
//  Created by alon muroch on 14/01/2016.
//
//

#import "GemsRootController.h"
#import "TGTelegraphDialogListCompanion.h"
#import "TGContactsController.h"
#import "TGAccountSettingsController.h"
#import "TGMainTabsController.h"
#import "SSignal.h"
#import "GemsMainTabsController.h"

@interface GemsRootController ()

@end

@implementation GemsRootController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _gemsWalletController = [[GemsWalletViewController alloc] initWithNibName:@"GemsWalletViewController" bundle:nil];
        
        
        self.mainTabsController = [[GemsMainTabsController alloc] init];
        [self.mainTabsController setViewControllers:[NSArray arrayWithObjects:self.contactsController, self.dialogListController, _gemsWalletController, self.accountSettingsController, nil]];
        [self.mainTabsController setSelectedIndex:1];
        
        [self.masterNavigationController setViewControllers:@[self.mainTabsController] animated:false];
    }
    return self;
}


@end
