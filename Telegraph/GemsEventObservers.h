//
//  GemsEventObservers.h
//  GetGems
//
//  Created by alon muroch on 4/2/15.
//
//

#import <Foundation/Foundation.h>
#import "GemsWalletViewController.h"

@interface GemsEventObservers : NSObject
+(instancetype)sharedInstance;
- (void)setupWithController:(GemsWalletViewController*)walletViewContorller;
@end
