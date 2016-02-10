//
//  PincodeManagerController.m
//  GetGems
//
//  Created by alon muroch on 9/1/15.
//
//

#import "PincodeManagerController.h"
#import "TGSwitchCollectionItem.h"
#import "TGDisclosureActionCollectionItem.h"
#import "TGHeaderCollectionItem.h"
#import "TGAppDelegate.h"

// GemsCore
#import <GemsCore/GemsCD.h>

// GemsUI
#import <GemsUI/GemsPinCodeView.h>
#import <GemsUI/UserNotifications.h>

@interface PincodeManagerController ()
{
    TGSwitchCollectionItem *_gemsCell, *_btcCell;
}

@end

@implementation PincodeManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(IS_IPAD) {
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:GemsLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(close)]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        [self setTitleText:GemsLocalized(@"Pincode")];
        
        // enable pincode header
        TGHeaderCollectionItem *header = [[TGHeaderCollectionItem alloc] initWithTitle:GemsLocalized(@"SetPincode")];
        
        
        // enable/ disable pincode for gems, btc
        _gemsCell = [[TGSwitchCollectionItem alloc] initWithTitle:GemsLocalized(@"Gems") icon:nil isOn:[PincodePolicy pincodeProtected:_G.type]];
        _gemsCell.interfaceHandle = self.actionHandle;
        _btcCell = [[TGSwitchCollectionItem alloc] initWithTitle:GemsLocalized(@"GemsBTC") icon:nil isOn:[PincodePolicy pincodeProtected:_B.type]];
        _btcCell.interfaceHandle = self.actionHandle;
        
        NSArray *currencyForSwitching;
        if([_B isActive])
            currencyForSwitching = @[header, _gemsCell, _btcCell];
        else
            currencyForSwitching = @[header, _gemsCell];
        TGCollectionMenuSection  *newSection = [[TGCollectionMenuSection alloc] initWithItems:currencyForSwitching];
        [self.menuSections addSection:newSection];
        
        // change pincode
        CDGemsUser *user = [CDGemsUser MR_findFirst];
        if(user.pinCodeHash) {
            TGDisclosureActionCollectionItem *changePincode = [[TGDisclosureActionCollectionItem alloc] initWithTitle:GemsLocalized(@"ChangePincode") icon:nil action:@selector(changePincode)];
            [changePincode setDeselectAutomatically:YES];
            
            TGCollectionMenuSection  *newSection = [[TGCollectionMenuSection alloc] initWithItems:@[changePincode]];
            [self.menuSections addSection:newSection];
        }
    }
    return self;
}

- (void)close {
    dismissController(YES);
}

- (void)changePincode
{
    CDGemsUser *user = [CDGemsUser MR_findFirst];
    
    GemsPinCodeView *v = [GemsPinCodeView new];
    [v changePincode:user.pinCodeHash completion:^(BOOL result, NSDictionary *data, NSString *errorString) {
        if(result) {
            NSString *pincodehash = [data[@"didRemovePincode"] boolValue] ? nil:data[@"pinHash"];
            if(!pincodehash && [_B isActive])
            {
                [UserNotifications showUserMessage:GemsLocalized(@"CannotRemovePincodeWhenBtcActive")];
                return ;
            }
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                CDGemsUser *user = [CDGemsUser MR_findFirstInContext:localContext];
                user.pinCodeHash = pincodehash;
            } completion:^(BOOL contextDidSave, NSError *error) {
                
            }];
        }
    }];
}

- (void)setPincode:(void(^)(BOOL didSet))completion
{
    CDGemsUser *user = [CDGemsUser MR_findFirst];
    if(user.pinCodeHash) {
        if(completion)
            completion(AUTHENTICATED);
        return;
    }
    
    GemsPinCodeView *v = [GemsPinCodeView new];
    [v setPinWithCompletion:^(BOOL result, NSDictionary *data, NSString *errorString) {
        if(result) {
            // set pincode hash
            NSString *pincodehash = data[@"pinHash"];
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                CDGemsUser *user = [CDGemsUser MR_findFirstInContext:localContext];
                user.pinCodeHash = pincodehash;
            } completion:^(BOOL contextDidSave, NSError *error) {
                if(completion)
                    completion(AUTHENTICATED);
            }];
        }
    }];
}

#pragma mark - ASWatch
- (void)actionStageActionRequested:(NSString *)action options:(id)__unused options
{
    if ([action isEqualToString:@"switchItemChanged"])
    {
        if (options[@"item"] == _gemsCell)
        {
            [self handleCurrencyPincodeProtectionChange:_G];
        }
        
        if (options[@"item"] == _btcCell)
        {
            [self handleCurrencyPincodeProtectionChange:_B];
        }
    }
}

- (void)handleCurrencyPincodeProtectionChange:(Currency*)currency
{
    if([PincodePolicy pincodeProtected:currency.type]) { // has policy, remove it
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"currencyType == %d", currency.type];
            [PincodePolicy MR_deleteAllMatchingPredicate:predicate inContext:localContext];
        } completion:^(BOOL contextDidSave, NSError __unused *error) {
            if(!contextDidSave)
            {
                [UserNotifications showUserMessage:@"Failed to set pincode policy"];
            }
            else {
                // if no policies left, delete pincode
                if([PincodePolicy MR_findAll].count == 0 && ![_B isActive]) {
                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                        CDGemsUser *user = [CDGemsUser MR_findFirstInContext:localContext];
                        user.pinCodeHash = nil;
                    }];
                }
            }
        }];
    }
    else { // no policy, create one
        [self setPincode:^(BOOL didSet){
            if(didSet) {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    [PincodePolicy createPolicyInContext:localContext forCurrency:currency.type];
                } completion:^(BOOL contextDidSave, NSError __unused *error) {
                    if(!contextDidSave)
                    {
                        [UserNotifications showUserMessage:@"Failed to set pincode policy"];
                    }
                }];
            }
        }];
    }
}

@end
