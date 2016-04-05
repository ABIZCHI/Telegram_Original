//
//  StartUsingPaykeyController.m
//  GetGems
//
//  Created by alon muroch on 03/03/2016.
//
//

#import "StartUsingPaykeyController.h"
#import <QuartzCore/QuartzCore.h>

@implementation StartUsingPaykeyController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _btnNext.layer.cornerRadius = 20.0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    [GemsAnalytics track:KbActivateClicked args:nil];
}

@end
