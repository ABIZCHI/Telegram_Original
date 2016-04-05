//
//  InstructionsController.m
//  GetGems
//
//  Created by alon muroch on 03/03/2016.
//
//

#import "InstructionsController.h"
#import "KbHelper.h"
#import "OnboardingNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import <PBJVideoPlayer/PBJVideoPlayer.h>

// GemsUI
#import <GemsUI/FXBlurView.h>
#import <GemsUI/UserNotifications.h>

// GemsCore
#import <GemsCore/Macros.h>

@interface InstructionsController () {
    NSTimer *_timer;
    PBJVideoPlayerController *_playerVC;
    
}

@property (nonatomic, strong) IBOutlet UIView *videoContainer;
@property (nonatomic, strong) IBOutlet UIButton *btnGoToSettings;
@property (nonatomic, strong) IBOutlet UILabel *lblInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@end

@implementation InstructionsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _lblInfo.text = @"The keyboard needs 'Full Access' to connect to the internet.\nYour personal info is never stored or transmitted";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"instrc_clip" ofType:@"mov"];
    
    _playerVC = [[PBJVideoPlayerController alloc] init];
    _playerVC.view.frame = self.videoContainer.bounds;
    _playerVC.videoPath = path;
    [self addChildViewController:_playerVC];
    [_videoContainer addSubview:_playerVC.view];
    [_playerVC didMoveToParentViewController:self];
    _playerVC.playbackLoops = true;
    _playerVC.volume = 0;
    
    [self showBlurredView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(timerDidFire) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
     _playerVC.view.frame = self.videoContainer.bounds;
}

- (void)timerDidFire {
    if([InstructionsController isCustomKeyboardEnabled]) {
        [_timer invalidate];
        [self performSegueWithIdentifier:@"start_using_paykey_segue" sender:nil];
    }
}

- (void)showBlurredView {
    UIView *keyView = [UIApplication sharedApplication].keyWindow;
    
    // dark bg
    UIView *shadow = [[UIView alloc] initWithFrame:keyView.frame];
    shadow.backgroundColor = [UIColor blackColor];
    shadow.alpha = 0.15f;
    shadow.tag = 1000;
    [keyView addSubview:shadow];
    
    FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:keyView.frame];
    blurView.dynamic = NO;
    blurView.blurRadius = 20.0f;
    blurView.tintColor = [UIColor blackColor];
    blurView.tag = 1001;
    [keyView addSubview:blurView];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(50,
                                                             blurView.frame.size.height / 2 - 50,
                                                             blurView.frame.size.width - 100,
                                                             100)];
    lbl.textColor = [UIColor whiteColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = [UIFont systemFontOfSize:26.0f];
    lbl.numberOfLines = 0;
    lbl.text = @"See the instruction video to learn how to install the keyboard";
    lbl.tag = 1002;
    [keyView addSubview:lbl];
    
    DELAY(6, ^{
        UIView *keyView = [UIApplication sharedApplication].keyWindow;
        UIView *shadow = [keyView viewWithTag:1000];
        UIView *blur = [keyView viewWithTag:1001];
        UILabel *lbl = (UILabel*)[keyView viewWithTag:1002];
        
        if (shadow.superview != nil) { // if bg tap was previously fired
            [shadow removeFromSuperview];
            [blur removeFromSuperview];
            [lbl removeFromSuperview];
            
            [_playerVC playFromBeginning];
        }
    });
    
    blurView.backgroundTapped = ^ {
        UIView *keyView = [UIApplication sharedApplication].keyWindow;
        UIView *shadow = [keyView viewWithTag:1000];
        UIView *blur = [keyView viewWithTag:1001];
        UILabel *lbl = (UILabel*)[keyView viewWithTag:1002];
        
        [shadow removeFromSuperview];
        [blur removeFromSuperview];
        [lbl removeFromSuperview];
        
        [_playerVC playFromBeginning];
    };
}

+ (BOOL)isCustomKeyboardEnabled {
    BOOL ret = [KbHelper didInstallKeyboard];
    if (ret) {
        [KbHelper setIsExpectingCrashAfterAllowedFullAccess];
        
        [GemsAnalytics track:KbInstalled args:nil];
    }
    
    return ret;
}

- (IBAction)btnGoToSettingsPressed:(id)__unused sender {
    [UserNotifications showUserMessage:@"Don't forget to return to GetGems after you install the keyboard" afterOk:^{
        NSURL *url = [NSURL URLWithString:@"prefs:root=General&path=Keyboard/KEYBOARDS"];
        [[UIApplication sharedApplication] openURL:url];
    }];
    
    [GemsAnalytics track:KbEnableClicked args:nil];
}

- (IBAction)closePressed:(id) __unused sender {
    OnboardingNavigationController *nav = (OnboardingNavigationController *)self.navigationController;
    [nav signalFinised];
    
    [GemsAnalytics track:KbSetupClosed args:@{@"stage" : @"after_intro"}];
}


@end
