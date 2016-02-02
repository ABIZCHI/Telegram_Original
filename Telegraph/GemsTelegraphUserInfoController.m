//
//  GemsTelegraphUserInfoController.m
//  GetGems
//
//  Created by alon muroch on 4/8/15.
//
//

#import "GemsTelegraphUserInfoController.h"
#import "TGUserInfoUsernameCollectionItem.h"
#import "TGAppDelegate.h"

// GemsCore
#import <GemsCore/GemsCD.h>

@interface GemsTelegraphUserInfoController ()

@property(nonatomic, strong) NSString *gemsUserName;

@end

@implementation GemsTelegraphUserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    if(IS_IPAD) {
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:GemsLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closePressed)]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closePressed
{
//    TGAppDelegateInstance.tabletMainViewController.detailViewController = nil;
}

- (void)_updatePhonesAndActions
{
    [super _updatePhonesAndActions];
}

@end
