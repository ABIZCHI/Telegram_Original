/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

#import "ActionStage.h"

#import "TGViewController.h"
#import "TGDialogListCell.h"
#import "TGConversation.h"
#import "TGSearchDisplayMixin.h"
#import "TGSearchBar.h"

extern NSString *authorNameYou;

@class TGDialogListCompanion;

@interface TGDialogListController : TGViewController <ASWatcher, GEMS_PROTOCOL_EXTERN UITableViewDelegate, GEMS_PROTOCOL_EXTERN UITableViewDataSource>

@property (nonatomic, strong, readonly) ASHandle *actionHandle;

@property (nonatomic, strong) TGDialogListCompanion *dialogListCompanion;

@property (nonatomic) bool canLoadMore;

@property (nonatomic) bool doNotHideSearchAutomatically;

@property (nonatomic) bool isDisplayingSearch;

GEMS_PROPERTY_EXTERN @property (nonatomic, strong) UITableView *tableView;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) UILabel *titleLabel;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) NSMutableArray *listModel;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) NSArray *searchResultsSections;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGSearchDisplayMixin *searchMixin;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) SMetaDisposable *searchDisposable;
GEMS_PROPERTY_EXTERN @property (nonatomic, assign) bool didSelectMessage;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGSearchBar *searchBar;;
GEMS_METHOD_EXTERN - (void)prepareCell:(TGDialogListCell *)cell forConversation:(TGConversation *)conversation animated:(bool)animated isSearch:(bool)isSearch;
GEMS_METHOD_EXTERN - (void)updateEmptyListContainer;
GEMS_METHOD_EXTERN - (void)setupEditingMode:(bool)editing setupTable:(bool)setupTable;
GEMS_METHOD_EXTERN - (void)selectConversationWithId:(int64_t)conversationId;

+ (void)setLastAppearedConversationId:(int64_t)conversationId;

+ (void)setDebugDoNotJump:(bool)debugDoNotJump;
+ (bool)debugDoNotJump;

- (id)initWithCompanion:(TGDialogListCompanion *)companion;

- (void)startSearch;

- (void)resetState;
- (void)dialogListFullyReloaded:(NSArray *)items;
- (void)dialogListItemsChanged:(NSArray *)insertedIndices insertedItems:(NSArray *)insertedItems updatedIndices:(NSArray *)updatedIndices updatedItems:(NSArray *)updatedItems removedIndices:(NSArray *)removedIndices;

- (void)selectConversationWithId:(int64_t)conversationId;

- (void)searchResultsReloaded:(NSDictionary *)items searchString:(NSString *)searchString;

- (void)titleStateUpdated:(NSString *)text isLoading:(bool)isLoading;

- (void)userTypingInConversationUpdated:(int64_t)conversationId typingString:(NSString *)typingString;

- (void)updateDatabasePassword;

- (void)updateSearchConversations:(NSArray *)conversations;

@end
