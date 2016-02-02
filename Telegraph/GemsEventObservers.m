//
//  GemsEventObservers.m
//  GetGems
//
//  Created by alon muroch on 4/2/15.
//
//

#import "GemsEventObservers.h"
#import <sys/stat.h>
#import <mach-o/dyld.h>

// Currencies
#import <GemsCurrencyManager/BRSPVWalletManager.h>

// BreadWallet
#import <BreadWalletCore/Reachability.h>
#import <BreadWalletCore/BRPeerManager.h>
#import <BreadWalletCore/UIImage+Blur.h>

@interface GemsEventObservers()

@property (nonatomic, strong) id foregroundObserver, activeObserver, reachabilityObserver, balanceObserver, syncStartedObserver, syncFinishedObserver, syncFailedObserver;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, weak) GemsWalletViewController *walletViewContorller;

@property (nonatomic, assign) NSTimeInterval timeout, start;

@end

@implementation GemsEventObservers

+(instancetype)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (void)setupWithController:(GemsWalletViewController*)walletViewContorller
{
    _walletViewContorller = walletViewContorller;
    
    // detect jailbreak so we can throw up an idiot warning, in viewDidLoad so it can't easily be swizzled out
    struct stat s;
    BOOL jailbroken = (stat("/bin/sh", &s) == 0) ? YES : NO; // if we can see /bin/sh, the app isn't sandboxed
    
    // some anti-jailbreak detection tools re-sandbox apps, so do a secondary check for any MobileSubstrate dyld images
    for (uint32_t count = _dyld_image_count(), i = 0; i < count && ! jailbroken; i++) {
        if (strstr(_dyld_get_image_name(i), "MobileSubstrate")) jailbroken = YES;
    }
    
#if TARGET_IPHONE_SIMULATOR
    jailbroken = NO;
#endif
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    BRSPVWalletManager *m = [BRSPVWalletManager sharedInstance];
    
    //
    self.foregroundObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
       if (! m.noWallet) {
           [[BRPeerManager sharedInstance] connect];
       }
       
       if (jailbroken && m.wallet.balance > 0) {
           [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WARNING", nil)
                                       message:NSLocalizedString(@"DEVICE SECURITY COMPROMISED\n"
                                                                 "Any 'jailbreak' app can access any other app's keychain data "
                                                                 "(and steal your bitcoins). "
                                                                 "Wipe this wallet immediately and restore on a secure device.", nil)
                                      delegate:self cancelButtonTitle:NSLocalizedString(@"ignore", nil)
                             otherButtonTitles:NSLocalizedString(@"wipe", nil), nil] show];
       }
       else if (jailbroken) {
           [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WARNING", nil)
                                       message:NSLocalizedString(@"DEVICE SECURITY COMPROMISED\n"
                                                                 "Any 'jailbreak' app can access any other app's keychain data "
                                                                 "(and steal your bitcoins).", nil)
                                      delegate:self cancelButtonTitle:NSLocalizedString(@"ignore", nil)
                             otherButtonTitles:NSLocalizedString(@"close app", nil), nil] show];
       }
   }];
    
    self.activeObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
//       uint64_t amount = [defs doubleForKey:SETTINGS_RECEIVED_AMOUNT_KEY];
//       
//       if (amount > 0) {
//           _balance = m.wallet.balance - amount;
//           self.balance = m.wallet.balance; // show received message bubble
//           [defs setDouble:0.0 forKey:SETTINGS_RECEIVED_AMOUNT_KEY];
//           [defs synchronize];
//       }
   }];
    
    self.reachabilityObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:nil
                                                  usingBlock:^(NSNotification *note) {
          if (! m.noWallet && self.reachability.currentReachabilityStatus != NotReachable &&
              [[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
              [[BRPeerManager sharedInstance] connect];
          }
      }];
    
    self.balanceObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification object:nil queue:nil
                                                  usingBlock:^(NSNotification *note) {
          if ([[BRPeerManager sharedInstance] syncProgress] < 1.0) return; // wait for sync

          if (self.reachability.currentReachabilityStatus != NotReachable &&
              [[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
              [[BRPeerManager sharedInstance] connect];
          }
      }];
    
    self.syncStartedObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncStartedNotification object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
           NSLog(@"Bitocin SPV wallet sync started");
           if (self.reachability.currentReachabilityStatus == NotReachable) return;
           
           [self updateProgress];
       }];
    
    self.syncFinishedObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFinishedNotification object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
           NSLog(@"Bitocin SPV wallet sync finished");
           _walletViewContorller.walletHeaderView.progressBar.hidden = YES;
                                                           
           if(_walletViewContorller)
               [_walletViewContorller refreshUi];
       }];
    
    self.syncFailedObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFailedNotification object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
      NSLog(@"Bitcoin SPV wallet sync failed");
      // show error
    }];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
}

- (void)updateProgress
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateProgress) object:nil];
    
    if(!_walletViewContorller.isViewLoaded) {
        [self performSelector:@selector(updateProgress) withObject:nil afterDelay:0.2];
        return;
    }
    
    if(_walletViewContorller.walletHeaderView.progressBar.hidden) _walletViewContorller.walletHeaderView.progressBar.hidden = NO;
    
    static int counter = 0;
    NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate] - self.start;
    double progress = [[BRPeerManager sharedInstance] syncProgress];
    
    if (self.timeout > 1.0 && 0.1 + 0.9*t/self.timeout < progress) progress = 0.1 + 0.9*t/self.timeout;
    if (progress <= DBL_EPSILON) progress = _walletViewContorller.walletHeaderView.progressBar.progress;
    
    if ((counter % 13) == 0) {
        [_walletViewContorller.walletHeaderView.progressBar setProgress:progress animated:progress > _walletViewContorller.walletHeaderView.progressBar.progress];
        
        if (progress > _walletViewContorller.walletHeaderView.progressBar.progress) {
            [self performSelector:@selector(setProgressTo:) withObject:@(progress) afterDelay:1.0];
        }
        else _walletViewContorller.walletHeaderView.progressBar.progress = progress;
    }
    else if ((counter % 13) >= 5) {
        [_walletViewContorller.walletHeaderView.progressBar setProgress:progress animated:progress > _walletViewContorller.walletHeaderView.progressBar.progress];
    }
    
    counter++;
    if (progress < 1.0) [self performSelector:@selector(updateProgress) withObject:nil afterDelay:0.2];
    else {
        _walletViewContorller.walletHeaderView.progressBar.progress = 0.0f;
        _walletViewContorller.walletHeaderView.progressBar.hidden = YES;
    }
}

- (void)setProgressTo:(NSNumber *)n
{
    _walletViewContorller.walletHeaderView.progressBar.progress = [n floatValue];
}

@end
