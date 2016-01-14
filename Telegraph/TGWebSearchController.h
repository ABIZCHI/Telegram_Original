#import "TGViewController.h"
#import "TGSearchBar.h"

@class TGImageInfo;

@interface TGWebSearchController : TGViewController

@property (nonatomic, copy) void (^dismiss)(void);
@property (nonatomic, copy) void (^completion)(TGWebSearchController *sender);
@property (nonatomic, copy) void (^avatarCreated)(UIImage *);
GEMS_PROPERTY_EXTERN @property (nonatomic, copy) void (^didFinishSearchingGifs)(NSArray *searchResults);

@property (nonatomic, readonly) bool avatarSelection;
@property (nonatomic, assign) bool disallowCaptions;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) NSArray *selectedGifItems;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGSearchBar *searchBar;

- (instancetype)initForAvatarSelection:(bool)avatarSelection;

- (NSArray *)selectedItemSignals:(id (^)(id, NSString *))imageDescriptionGenerator;

+ (void)clearRecents;
+ (void)addRecentSelectedItems:(NSArray *)items;
GEMS_METHOD_EXTERN + (NSArray *)recentSelectedItems;
GEMS_METHOD_EXTERN - (void)doneButtonPressed;
GEMS_METHOD_EXTERN - (void)searchBarSearchButtonClicked:(UISearchBar *)__unused searchBar;
@end
