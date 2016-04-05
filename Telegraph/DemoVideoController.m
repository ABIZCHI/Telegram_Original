//
//  DemoVideoController.m
//  GetGems
//
//  Created by alon muroch on 03/03/2016.
//
//

#import "DemoVideoController.h"
#import "OnboardingNavigationController.h"
#import <PBJVideoPlayer/PBJVideoPlayer.h>

@interface DemoVideoController () {
    PBJVideoPlayerController *_playerVC;
}

@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (weak, nonatomic) IBOutlet UIView *videoContainer;

@end

@implementation DemoVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _btnSkip.layer.cornerRadius = 20.0;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PayKeyDemo" ofType:@"mp4"];
    _playerVC = [[PBJVideoPlayerController alloc] init];
    _playerVC.view.frame = self.videoContainer.bounds;
    _playerVC.videoPath = path;
    [self addChildViewController:_playerVC];
    [_videoContainer addSubview:_playerVC.view];
    [_playerVC didMoveToParentViewController:self];
    [_playerVC playFromBeginning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressed:(id)sender {
    OnboardingNavigationController *nav = (OnboardingNavigationController *)self.navigationController;
    [nav signalFinised];
    
    [GemsAnalytics track:KbSetupClosed args:@{@"stage" : @"enabled"}];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _playerVC.view.frame = self.view.frame;
}

@end
