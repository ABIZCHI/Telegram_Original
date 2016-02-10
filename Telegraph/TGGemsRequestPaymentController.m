//
//  TGGemsRequestPaymentController.m
//  GemsUI
//
//  Created by alon muroch on 8/2/15.
//  Copyright (c) 2015 alon muroch. All rights reserved.
//

#import "TGGemsRequestPaymentController.h"
#import "TGAppDelegate.h"
#import "GemsNavigationController.h"

// GemsCore
#import <GemsCore/Macros.h>

@implementation TGGemsRequestPaymentController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(IS_IPAD) {
        [((GemsNavigationController*)self.navigationController) setNavigationBarHidden:YES];
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:GemsLocalized(@"GemsClose") style:UIBarButtonItemStylePlain target:self action:@selector(close)]];
    }
}

- (IBAction)close:(id)sender {
    dismissController(YES);
}

@end
