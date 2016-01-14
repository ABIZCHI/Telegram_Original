//
//  TGFaqController.m
//  GetGems
//
//  Created by alon muroch on 9/6/15.
//
//

#import "TGGemsFaqController.h"
#import "GemsNavigationController.h"
#import "TGAppDelegate.h"

// GemsCore
#import <Macros.h>

@interface TGGemsFaqController ()

@end

@implementation TGGemsFaqController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(IS_IPAD) {
        [((GemsNavigationController*)self.navigationController) setNavigationBarHidden:NO];
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(close)]];
    }
}

- (void)close {
    [TGAppDelegateInstance dismissViewControllerAnimated:YES];
}

@end
