//
//  TGGems.h
//  GetGems
//
//  Created by alon muroch on 7/8/15.
//
//

#import <Foundation/Foundation.h>
#import "ASWatcher.h"

// GemsUI
#import <GemsUI/GemsAppearance.h>

// GemsCore
#import <GemsCore/Gems.h>

#ifdef GEMS
#undef GEMS
#define GEMS [TGGems sharedInstance]
#endif

@interface TGGems : Gems <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

- (void)didBecomeActiveUIPrompts;
- (void)setupNetworkingAuthenticator;
- (void)resetBackupDialog;
- (void)showBackupDialogOnlyIfNeeded;
- (void)showPassphraseRecoveryView;
- (void)doLogoutWithCompletion:(void(^)())completion;

@end
