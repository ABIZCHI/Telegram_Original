//
//  GemsUsenameControllerViewController.m
//  GetGems
//
//  Created by alon muroch on 8/23/15.
//
//

#import "GemsUsenameController.h"
#import "ActionStage.h"

@interface GemsUsenameController ()

@end

@implementation GemsUsenameController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/applyUsername/"])
    {
        if (status == ASStatusSuccess)
        {
            if(self.completionBlock){
                self.completionBlock(self.usernameItem.username);
            }
            else {
                [super actorCompleted:status path:path result:result];
            }
        }
    }
    else {
        [super actorCompleted:status path:path result:result];
    }
}

@end
