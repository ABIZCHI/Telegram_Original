//
//  FeaturedAllController.h
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "TGViewController.h"

@interface FeaturedAllController : TGViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tblView;

- (void)setupWithData:(NSArray*)data;

@end
