//
//  HowToSwitchToPaykeyController.m
//  GetGems
//
//  Created by alon muroch on 03/03/2016.
//
//

#import "HowToSwitchToPaykeyController.h"
#import "ExtensionConst.h"
#import "NSUserDefaults+Keyboard.h"
#import "KbHelper.h"

@interface HowToSwitchToPaykeyController ()
{
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *finishedConstr;
@property (weak, nonatomic) IBOutlet UITextField *txv;

@end

@implementation HowToSwitchToPaykeyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [KBDefaults() setDidSwitchToPayKeyForTheFirstTime:false];
    
    _timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(timerDidFire) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_txv becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)timerDidFire {
    if ([self didActivatePaykey]) {
        [_timer invalidate];
        [_txv resignFirstResponder];
        
        [GemsAnalytics track:KbActivated args:nil];
        
        [KbHelper finishKeyboardInstallation]; // mark installation finished
        
        _finishedConstr.constant = 0.0;
        [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            double delayInSeconds = 2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSegueWithIdentifier:@"play_paykey_demo_segue" sender:nil];
            });
        }];
    }
}

- (BOOL)didActivatePaykey {
    return [KbHelper didActivateKeyboard];
}

@end
