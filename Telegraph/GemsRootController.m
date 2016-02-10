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
#import "GemsAccountSettingsController.h"
#import "TGMainTabsController.h"
#import "SSignal.h"
#import "GemsMainTabsController.h"
#import "GemsDialogListController.h"
#import "GemsContactsController.h"

@interface GemsRootController ()

@end

@implementation GemsRootController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _gemsWalletController = [[GemsWalletViewController alloc] initWithNibName:@"GemsWalletViewController" bundle:nil];
        
        _gemsAppStroeController = [[GemsStoreController alloc] initWithNibName:@"GemsStoreController" bundle:nil];
        
        self.accountSettingsController = [[GemsAccountSettingsController alloc] initWithUid:0];
        
        self.contactsController = [[GemsContactsController alloc] initWithContactsMode:TGContactsModeMainContacts | TGContactsModeRegistered | TGContactsModePhonebook | TGContactsModeSortByLastSeen];
        
        TGTelegraphDialogListCompanion *dialogListCompanion = [[TGTelegraphDialogListCompanion alloc] init];
        dialogListCompanion.showBroadcastsMenu = true;
        self.dialogListController = [[GemsDialogListController alloc] initWithCompanion:dialogListCompanion];
        
        self.mainTabsController = [[GemsMainTabsController alloc] init];
        [self.mainTabsController setViewControllers:[NSArray arrayWithObjects:self.contactsController, self.dialogListController, _gemsWalletController, _gemsAppStroeController, self.accountSettingsController, nil]];
        [self.mainTabsController setSelectedIndex:1];        
    }
    return self;
}


@end
