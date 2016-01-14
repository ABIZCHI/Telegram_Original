//
//  GemsAppStoreController.h
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import "TGViewController.h"
#import "StoreTableViewDataSource.h"

@interface GemsStoreController : TGViewController

@property (strong, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) StoreTableViewDataSource *tblDataSource;

@end
