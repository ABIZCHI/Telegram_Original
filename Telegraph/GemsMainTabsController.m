//
//  GemsMainTabsController.m
//  Telegraph
//
//  Created by alon muroch on 14/01/2016.
//
//

#import "GemsMainTabsController.h"
#import "GemsTabBar.h"

@interface GemsMainTabsController ()

@end

@implementation GemsMainTabsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.customTabBar removeFromSuperview];
    
    self.customTabBar = [[GemsTabBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [self tabBarHeight], self.view.frame.size.width, [self tabBarHeight])];
    self.customTabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.customTabBar.tabDelegate = self;
    [self.view insertSubview:self.customTabBar aboveSubview:self.tabBar];
    
    //_customTabBar.alpha = 0.5f;
    
    self.tabBar.hidden = true;
}

@end
