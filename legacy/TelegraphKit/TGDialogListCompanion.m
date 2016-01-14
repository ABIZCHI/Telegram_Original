#import "TGDialogListCompanion.h"
#import "TGDatabase.h"

@implementation TGDialogListCompanion

@synthesize dialogListController = _dialogListController;

@synthesize showListEditingControl = _showListEditingControl;
@synthesize forwardMode = _forwardMode;

@synthesize unreadCount = _unreadCount;

- (id)processSearchResultItem:(id)__unused item
{
    return nil;
}

- (id<TGDialogListCellAssetsSource>)dialogListCellAssetsSource
{
    return nil;
}

- (void)dialogListReady
{
    
}

- (void)clearData
{
    
}

- (void)loadMoreItems
{
    
}

- (void)composeMessage
{
    
}

- (void)navigateToBroadcastLists
{
}

- (void)navigateToNewGroup
{
}

- (void)conversationSelected:(TGConversation *)__unused conversation
{
}

- (void)deleteItem:(TGConversation *)__unused conversation animated:(bool)__unused animated
{
}

- (void)clearItem:(TGConversation *)__unused conversation animated:(bool)__unused animated
{
}

- (void)beginSearch:(NSString *)__unused queryString inMessages:(bool)__unused inMessages
{
    
}

- (void)searchResultSelectedUser:(TGUser *)__unused user
{
    
}

- (void)searchResultSelectedConversation:(TGConversation *)__unused conversation
{
    
}

- (void)searchResultSelectedConversation:(TGConversation *)__unused conversation atMessageId:(int)__unused messageId
{
    
}

- (void)searchResultSelectedMessage:(TGMessage *)__unused message
{
    
}

- (bool)shouldDisplayEmptyListPlaceholder
{
    return true;
}

- (void)wakeUp
{
    
}

- (void)resetLocalization
{
    
}

- (bool)isConversationOpened:(int64_t)__unused conversationId
{
    return false;
}

#pragma mark - custom hide conversations
- (void)checkForNotWantedConversations:(NSArray *)items
{
    self.removedConversationIndxsForGemsUsage = [[NSMutableIndexSet alloc] init];
    // remove bot conversations
    for(NSUInteger i=0 ; i < items.count ; i++)
    {
        TGConversation *conv = [items objectAtIndex:i];
        
        /**
         *  Patch for migration to v1.2.0
         *  In 1.2.0 we switched the logic for hidding GetGems bots, to path the migration
         *  we add the previous Auth bot manulally
         */
        {
            TGUser *user = [TGDatabaseInstance() loadUser:conv.conversationId];
            if([user.userName isEqualToString:@"getgemsprodbot03"])
            {
                if(![[TGDialogListCompanion hiddenConversations] containsObject:@(conv.conversationId)])
                    [TGDialogListCompanion hideConversationWithId:conv.conversationId];
                [self.removedConversationIndxsForGemsUsage addIndex:i];
            }
        }
        
        if([[TGDialogListCompanion hiddenConversations] containsObject:@(conv.conversationId)])
            [self.removedConversationIndxsForGemsUsage addIndex:i];
    }
    
    
}

+ (void)hideConversationWithId:(int64_t)cid
{
    if([[TGDialogListCompanion hiddenConversations] containsObject:@(cid)]) return;
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[self hiddenConversations]];
    [arr addObject:@(cid)];
    
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"HiddenConversationsKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray*)hiddenConversations
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"HiddenConversationsKey"];
}

@end
