//
//  GemsNavigationController.h
//  GetGems
//
//  Created by alon muroch on 3/18/15.
//
//

#import "TGNavigationController.h"

@interface GemsNavigationController : TGNavigationController

+ (GemsNavigationController *)navigationControllerWithRootController:(UIViewController *)controller;
+ (GemsNavigationController *)navigationControllerWithControllers:(NSArray *)controllers;
+ (GemsNavigationController *)navigationControllerWithControllers:(NSArray *)controllers navigationBarClass:(Class)navigationBarClass;

@end
