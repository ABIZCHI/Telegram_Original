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
#import "TGDialogListCell.h"
#import "ConversationMessageHandler.h"
#import "TGImageUtils.h"
#import "TGGlobalMessageSearchSignals.h"
#import "TGDialogListBroadcastsMenuCell.h"

#import "LDAdvertisingManager.h" // Advertising

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

    
    
    /**
      * Now after we filtered the hidden conversations, update the table view
     */
    
    NSMutableArray * adjustedArray = [self.listModel mutableCopy];
    [adjustedArray removeObjectsAtIndexes:self.dialogListCompanion.removedConversationIndxsForGemsUsage];
    
    int countBefore = (int)self.listModel.count;
    
    NSMutableArray *removedIndexPaths = [[NSMutableArray alloc] init];
    for (NSNumber *nRemovedIndex in removedIndices)
    {
        NSUInteger rowNumber = [self findCellRealIndex:[nRemovedIndex integerValue]];
        if (rowNumber == -1) {
            continue;
        }
        [self.listModel removeObjectAtIndex:[nRemovedIndex intValue]];
        [removedIndexPaths addObject:[NSIndexPath indexPathForRow:rowNumber inSection:1]];
    }
    
    if (removedIndexPaths.count != 0)
    {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:removedIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
    }
    
    int index = -1;
    for (NSNumber *nUpdatedIndex in updatedIndices)
    {
        index++;
        [self.listModel replaceObjectAtIndex:[nUpdatedIndex intValue] withObject:[updatedItems objectAtIndex:index]];
    }
    
    for (NSNumber *nUpdatedIndex in updatedIndices)
    {
        NSUInteger realIdx = [self findCellRealIndex:[nUpdatedIndex intValue]];
        if(realIdx == -1)
            continue;
        TGDialogListCell *cell = (TGDialogListCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:realIdx inSection:1]];
        if (cell != nil)
        {
            TGConversation *conversation = [self.listModel objectAtIndex:[nUpdatedIndex intValue]];
            [self prepareCell:cell forConversation:conversation animated:true isSearch:false];
        }
    }
    
    if ((countBefore == 0) != (self.listModel.count == 0))
    {
        [self updateEmptyListContainer];
        
        if (self.listModel.count == 0)
            [self setupEditingMode:false setupTable:true];
    }
}

- (NSUInteger)findCellRealIndex:(NSInteger)searchedIdx
{
    TGConversation *lookedConversation = [self.listModel objectAtIndex:searchedIdx];
    NSMutableArray *data = [NSMutableArray arrayWithArray:self.listModel];
    [data removeObjectsAtIndexes:self.dialogListCompanion.removedConversationIndxsForGemsUsage];
    
    NSInteger removedCnt = self.dialogListCompanion.removedConversationIndxsForGemsUsage.count;
    NSUInteger start = MAX(0,(searchedIdx - removedCnt - 1)) , end = MIN(data.count, (searchedIdx + removedCnt + 1));
    
    for(NSUInteger i = start; i < end ; i++)
    {
        TGConversation *c = [data objectAtIndex:i];
        if(c.conversationId == lookedConversation.conversationId)
            return i;
    }
    
    return -1;
}

- (void)dialogListFullyReloaded:(NSArray *)items {
    [self.dialogListCompanion checkForNotWantedConversations:items];
    [super dialogListFullyReloaded:items];
}
- (void)selectConversationWithId:(int64_t)conversationId
{
    bool found = false;
    
    int index = -1;
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.listModel];
    [arr removeObjectsAtIndexes:self.dialogListCompanion.removedConversationIndxsForGemsUsage];
    
    for (TGConversation *conversation in arr)
    {
        index++;
        
        if (conversation.conversationId == conversationId)
        {
            UITableViewScrollPosition scrollPosition = UITableViewScrollPositionNone;
            
            CGRect convertRect = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]] toView:self.view];
            if (convertRect.origin.y + convertRect.size.height > self.view.frame.size.height - self.controllerInset.bottom)
                scrollPosition = UITableViewScrollPositionBottom;
            else if (convertRect.origin.y < self.controllerInset.top)
                scrollPosition = UITableViewScrollPositionTop;
            
            if (self.searchMixin.isActive)
                scrollPosition = UITableViewScrollPositionNone;
            
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1] animated:false scrollPosition:scrollPosition];
            
            found = true;
            
            break;
        }
    }
    
    if (!found && [self.tableView indexPathForSelectedRow] != nil)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:false];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static bool canSelect = true;
    if (canSelect)
    {
        canSelect = false;
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           canSelect = true;
                       });
    }
    else
        return;
    
    if (TGIsPad())
        [self.view endEditing:true];
    
    if (tableView == self.tableView)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.selectionStyle != UITableViewCellSelectionStyleNone)
        {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.listModel];
            [arr removeObjectsAtIndexes:self.dialogListCompanion.removedConversationIndxsForGemsUsage];
            
            TGConversation *conversation = nil;
            if (indexPath.row < (NSInteger)arr.count)
                conversation = [arr objectAtIndex:indexPath.row];
            
            if (conversation != nil)
            {
                [self.dialogListCompanion conversationSelected:conversation];
                [[LDAdvertisingManager sharedManager] didSelectConversation:conversation];
            }
            
            if (self.dialogListCompanion.forwardMode || self.dialogListCompanion.privacyMode)
                [self.tableView deselectRowAtIndexPath:indexPath animated:true];
        }
        
        if (self.dialogListCompanion.forwardMode)
            [tableView deselectRowAtIndexPath:indexPath animated:true];
    }
    else
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGConversation *conversation = nil;
    
    if (tableView == self.tableView)
    {
        if (indexPath.section != 0)
        {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.listModel];
            [arr removeObjectsAtIndexes:self.dialogListCompanion.removedConversationIndxsForGemsUsage];
            if (indexPath.row < arr.count)
                conversation = [arr objectAtIndex:indexPath.row];
        }
    }
    
    if (tableView == self.tableView)
    {
        if (conversation != nil)
        {
            static NSString *MessageCellIdentifier = @"MC";
            TGDialogListCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageCellIdentifier];
            
            if (cell == nil)
            {
                if (cell == nil)
                {
                    cell = [[TGDialogListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageCellIdentifier assetsSource:[self.dialogListCompanion dialogListCellAssetsSource]];
                    cell.watcherHandle = self.actionHandle;
                    cell.enableEditing = ![self.dialogListCompanion forwardMode] && !self.dialogListCompanion.privacyMode;
                }
            }
            
            [self prepareCell:cell forConversation:conversation animated:false isSearch:false];
            
            return cell;
        }
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)prepareCell:(TGDialogListCell *)cell forConversation:(TGConversation *)conversation animated:(bool)animated isSearch:(bool)isSearch
{
    [super prepareCell:cell forConversation:conversation animated:animated isSearch:isSearch];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        if (section == 0)
            return (TGIsPad() && self.dialogListCompanion.showBroadcastsMenu) ? 1 : 0;
        
        [self.dialogListCompanion checkForNotWantedConversations:self.listModel];
        return self.listModel.count - self.dialogListCompanion.removedConversationIndxsForGemsUsage.count;
    }
    else
        return [(NSArray *)self.searchResultsSections[section][@"items"] count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView && self.dialogListCompanion.removedConversationIndxsForGemsUsage != 0)
    {
        NSMutableArray * adjustedListModel = [[NSMutableArray alloc] initWithArray:self.listModel];
        [adjustedListModel removeObjectsAtIndexes:self.dialogListCompanion.removedConversationIndxsForGemsUsage];
        
        if (indexPath.row >= (NSInteger)adjustedListModel.count) {
            return;
        }
        
        TGConversation * conv = [adjustedListModel objectAtIndex:indexPath.row];
        NSInteger realRow = [self.listModel indexOfObject:conv];

        NSIndexPath * realIndexPath = [NSIndexPath indexPathForRow:realRow inSection:indexPath.section];
        [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:realIndexPath];

    }
    else
    {
        [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

@end
