//
//  GemsRootController.h
//  Telegraph
//
//  Created by alon muroch on 14/01/2016.
//
//

#import "TGRootController.h"
#import "GemsWalletViewController.h"
#import "GemsStoreController.h"

@interface GemsRootController : TGRootController

@property(nonatomic, strong) GemsWalletViewController *gemsWalletController;
@property(nonatomic, strong) GemsStoreController *gemsAppStroeController;

@end
