//
//  FeaturedAllController.m
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "FeaturedAllController.h"
#import "FeaturedAllCell.h"
#import "FeatureController.h"
#import "TGAppDelegate.h"
#import "TGImageUtils.h"

// GemsCore
#import <GemsCore/GemsLocalization.h>

@interface FeaturedAllController ()
{
    NSArray *_data;
}

@end

@implementation FeaturedAllController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(TGIsPad()) {
        [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:GemsLocalized(@"Common.Close") style:UIBarButtonItemStylePlain target:self action:@selector(closePressed)]];
    }
    
    [_tblView reloadData];
}

- (void)closePressed
{
//    TGAppDelegateInstance.tabletMainViewController.detailViewController = nil;
}

- (void)setupWithData:(NSArray*)data
{
    _data = data;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeaturedAllCell *cell = (FeaturedAllCell *)[tableView dequeueReusableCellWithIdentifier:[FeaturedAllCell cellIdentifier]];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FeaturedAllCell" owner:self options:nil];
        cell = (FeaturedAllCell *)[nib objectAtIndex:0];
    }
    
    [cell bindCell:[_data objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FeaturedAllCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreItemData *d = [_data objectAtIndex:indexPath.row];
    
    FeatureController *v = [[FeatureController alloc] initWithNibName:@"FeatureController" bundle:nil];
    [v setupWithData:d];
    [self.navigationController pushViewController:v animated:YES];
}

@end
