//
//  TGGemsIntroController.m
//  GetGems
//
//  Created by alon muroch on 8/2/15.
//
//

#import "TGGemsIntroController.h"

#import "GemsNavigationController.h"

@implementation TGGemsIntroController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [((GemsNavigationController*)self.navigationController) setNavigationBarHidden:YES];
}

@end
