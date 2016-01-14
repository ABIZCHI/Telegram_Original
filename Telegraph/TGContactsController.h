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
#import "TGTokenFieldView.h"
#import "TGUser.h"

typedef enum {
    TGContactsModeRegistered = 1,
    TGContactsModePhonebook = 2,
    TGContactsModeSearchDisabled = 4,
    TGContactsModeMainContacts = 8,
    TGContactsModeInvite = 16 | 2,
    TGContactsModeSelectModal = 32,
    TGContactsModeShowSelf = 64,
    TGContactsModeClearSelectionImmediately = 128,
    TGContactsModeCompose = 256 | 1 | 4,
    TGContactsModeModalInvite = 512 | 16 | 2,
    TGContactsModeModalInviteWithBack = 1024 | 512 | 16 | 2,
    TGContactsModeCreateGroupOption = 2048,
    TGContactsModeCombineSections = 4096,
    TGContactsModeManualFirstSection = 8192,
    TGContactsModeCreateGroupLink = (2 << 14),
    TGContactsModeSortByLastSeen = (2 << 15),
    TGContactsModeIgnorePrivateBots = (2 << 16)
} TGContactsMode;

@interface TGContactsController : TGViewController <GEMS_PROTOCOL_EXTERN UITableViewDelegate, GEMS_PROTOCOL_EXTERN UITableViewDataSource, TGViewControllerNavigationBarAppearance, ASWatcher>

GEMS_PROPERTY_EXTERN @property (nonatomic, strong) NSArray *localSearchResults;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) NSArray *globalSearchResults;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGTokenFieldView *tokenFieldView;
GEMS_ADDED_PROPERTY  @property(nonatomic, strong) NSString *referralURL;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) UIView *inviteContainer;

@property (nonatomic) bool loginStyle;

@property (nonatomic, strong, readonly) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *watcherHandle;

@property (nonatomic) int contactListVersion;
@property (nonatomic) int phonebookVersion;

@property (nonatomic) bool drawFakeNavigationBar;

@property (nonatomic, strong) NSString *customTitle;

@property (nonatomic, readonly) int contactsMode;
@property (nonatomic) int usersSelectedLimit;

@property (nonatomic, strong) NSArray *disabledUsers;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSString *composePlaceholder;

@property (nonatomic) bool deselectAutomatically;

- (id)initWithContactsMode:(int)contactsMode;

- (void)clearData;

- (void)deselectRow;

- (int)selectedContactsCount;
- (NSArray *)selectedComposeUsers;
- (NSArray *)selectedContactsList;
- (void)setUsersSelected:(NSArray *)users selected:(NSArray *)selected callback:(bool)callback;
- (void)contactSelected:(TGUser *)user;
- (void)contactDeselected:(TGUser *)user;
- (void)actionItemSelected;
- (void)encryptionItemSelected;
- (void)channelsItemSelected;
- (void)singleUserSelected:(TGUser *)user;

- (void)contactActionButtonPressed:(TGUser *)user;

- (void)deleteUserFromList:(int)uid;

- (CGFloat)itemHeightForFirstSection;
- (NSInteger)numberOfRowsInFirstSection;
- (UITableViewCell *)cellForRowInFirstSection:(NSInteger)row;
- (void)didSelectRowInFirstSection:(NSInteger)row;
- (bool)shouldDisplaySectionIndices;
- (void)commitDeleteItemInFirstSection:(NSInteger)row;

GEMS_METHOD_EXTERN - (void)pushInviteContactsWithShouldSimulateSelectAll:(BOOL)shouldSimulateSelectAllPush;
GEMS_METHOD_EXTERN - (void)selectAllButtonPressed;
GEMS_METHOD_EXTERN - (void)updateSelectionInterface;
GEMS_METHOD_EXTERN - (void)updateTokenField;

@end
