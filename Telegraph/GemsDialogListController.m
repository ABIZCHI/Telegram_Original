//
//  GemsDialogListController.m
//  GetGems
//
//  Created by alon muroch on 3/18/15.
//
//

#import "GemsDialogListController.h"
#import "TGConversation.h"
#import "TGTelegraph.h"
#import "TGDatabase.h"
#import "TGUser+Telegraph.h"
#import "TGDialogListCompanion.h"

@interface GemsDialogListController ()

@end

@implementation GemsDialogListController

- (id)initWithCompanion:(TGDialogListCompanion *)companion
{
    self = [super initWithCompanion:companion];
    if(self)
    {
        self.dialogListCompanion.dialogListController = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadView
{
    [super loadView];
    [self.titleLabel setTextColor:[GemsAppearance navigationTextColor]];
}

- (void)dialogListItemsChanged:(NSArray *)insertedIndices insertedItems:(NSArray *)insertedItems updatedIndices:(NSArray *)updatedIndices updatedItems:(NSArray *)updatedItems removedIndices:(NSArray *)removedIndices
{
    if(self.dialogListCompanion.removedConversationIndxsForGemsUsage.count == 0) {
        [super dialogListItemsChanged:insertedIndices insertedItems:insertedItems updatedIndices:updatedIndices updatedItems:updatedItems removedIndices:removedIndices];
        return;
    }
    
    NSMutableArray *insetedIndicesMutable = [NSMutableArray arrayWithArray:insertedIndices];
    NSMutableArray *insertedItemsMutable = [NSMutableArray arrayWithArray:insertedItems];
    NSMutableArray *updatedIndicesMutable = [NSMutableArray arrayWithArray:updatedIndices];
    NSMutableArray *updatedItemsMutable = [NSMutableArray arrayWithArray:updatedItems];
    NSMutableArray *removedIndicesMutable = [NSMutableArray arrayWithArray:removedIndices];
    
    // inserted
    NSMutableIndexSet *forRemoval = [[NSMutableIndexSet alloc] init];
    for (NSUInteger i=0 ; i< insetedIndicesMutable.count ; i++)
    {
        NSNumber *idx = (NSNumber *)[insetedIndicesMutable objectAtIndex:i];
        if([self.dialogListCompanion.removedConversationIndxsForGemsUsage containsIndex:[idx unsignedIntegerValue]])
        {
            [forRemoval addIndex:i];
        }
    }
    [insetedIndicesMutable removeObjectsAtIndexes:forRemoval];
    [insertedItemsMutable removeObjectsAtIndexes:forRemoval];
    
    // updated
    forRemoval = [[NSMutableIndexSet alloc] init];
    for (NSUInteger i=0 ; i< updatedIndicesMutable.count ; i++)
    {
        NSNumber *idx = (NSNumber *)[updatedIndicesMutable objectAtIndex:i];
        if([self.dialogListCompanion.removedConversationIndxsForGemsUsage containsIndex:[idx unsignedIntegerValue]])
        {
            [forRemoval addIndex:i];
        }
    }
    [updatedIndicesMutable removeObjectsAtIndexes:forRemoval];
    [updatedItemsMutable removeObjectsAtIndexes:forRemoval];
    
    // removed
    forRemoval = [[NSMutableIndexSet alloc] init];
    for (NSUInteger i=0 ; i< removedIndicesMutable.count ; i++)
    {
        NSNumber *idx = (NSNumber *)[removedIndicesMutable objectAtIndex:i];
        if([self.dialogListCompanion.removedConversationIndxsForGemsUsage containsIndex:[idx unsignedIntegerValue]])
        {
            [forRemoval addIndex:i];
        }
    }
    [removedIndicesMutable removeObjectsAtIndexes:forRemoval];

    [super dialogListItemsChanged:insetedIndicesMutable insertedItems:insertedItemsMutable updatedIndices:updatedIndicesMutable updatedItems:updatedItemsMutable removedIndices:removedIndicesMutable];
}



@end
