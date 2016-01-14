#import "TGCollectionMenuController.h"
#import "TGUsernameCollectionItem.h"

GEMS_PROPERTY_EXTERN
typedef enum {
    TGUsernameControllerUsernameStateNone,
    TGUsernameControllerUsernameStateValid,
    TGUsernameControllerUsernameStateTooShort,
    TGUsernameControllerUsernameStateInvalidCharacters,
    TGUsernameControllerUsernameStateStartsWithNumber,
    TGUsernameControllerUsernameStateTaken,
    TGUsernameControllerUsernameStateChecking
} TGUsernameControllerUsernameState;

@interface TGUsernameController : TGCollectionMenuController<GEMS_PROTOCOL_EXTERN ASWatcher>

GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGUsernameCollectionItem *usernameItem;

@end
