//
//  GemsNavigationController.m
//  GetGems
//
//  Created by alon muroch on 3/18/15.
//
//

#import "GemsNavigationController.h"
#import "TGAppDelegate.h"

// GemsUI
#import <GemsAppearance.h>

@interface GemsNavigationController ()

@end

@implementation GemsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

+ (GemsNavigationController *)navigationControllerWithRootController:(UIViewController *)controller
{
    GemsNavigationController *ret = (GemsNavigationController *)[super navigationControllerWithRootController:controller];
    return [self initGemsTheme:ret];
}

+ (GemsNavigationController *)navigationControllerWithControllers:(NSArray *)controllers
{
    GemsNavigationController *ret =  (GemsNavigationController *)[super navigationControllerWithControllers:controllers];
   return [self initGemsTheme:ret];
}

+ (GemsNavigationController *)navigationControllerWithControllers:(NSArray *)controllers navigationBarClass:(Class)navigationBarClass
{
    GemsNavigationController *ret =  (GemsNavigationController *)[super navigationControllerWithControllers:controllers navigationBarClass:navigationBarClass];
    return [self initGemsTheme:ret];
}

+(GemsNavigationController *)initGemsTheme:(GemsNavigationController *)nav
{
    [nav.navigationBar setTintColor:[GemsAppearance navigationBarTintColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [GemsAppearance navigationTextColor]}];
    
    return nav;
}

@end
