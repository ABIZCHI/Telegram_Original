//
//  PincodeManagerController.h
//  GetGems
//
//  Created by alon muroch on 9/1/15.
//
//

#import "TGCollectionMenuController.h"
#import "ASHandle.h"

@interface PincodeManagerController : TGCollectionMenuController <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

@end
