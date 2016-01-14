#import "TGViewController.h"
#import "TGSearchBar.h"

@class TGImageInfo;
@class TGSuggestionContext;

@interface TGWebSearchController : TGViewController

@property (nonatomic, copy) void (^avatarCompletionBlock)(UIImage *);
@property (nonatomic, copy) void (^completionBlock)(TGWebSearchController *sender);
@property (nonatomic, copy) void (^dismiss)(void);
GEMS_PROPERTY_EXTERN @property (nonatomic, copy) void (^didFinishSearchingGifs)(NSArray *searchResults);

@property (nonatomic, weak) TGNavigationController *parentNavigationController;

@property (nonatomic, readonly) bool avatarSelection;
@property (nonatomic, assign) bool captionsEnabled;
@property (nonatomic, strong) TGSuggestionContext *suggestionContext;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) NSArray *selectedGifItems;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGSearchBar *searchBar;

- (instancetype)initForAvatarSelection:(bool)avatarSelection embedded:(bool)embedded;

- (NSArray *)selectedItemSignals:(id (^)(id, NSString *))imageDescriptionGenerator;

+ (void)clearRecents;
+ (void)addRecentSelectedItems:(NSArray *)items;

- (void)presentEmbeddedInController:(UIViewController *)controller animated:(bool)animated;
- (void)dismissEmbeddedAnimated:(bool)animated;

GEMS_METHOD_EXTERN + (NSArray *)recentSelectedItems;
GEMS_METHOD_EXTERN - (void)doneButtonPressed;
GEMS_METHOD_EXTERN - (void)searchBarSearchButtonClicked:(UISearchBar *)__unused searchBar;
@end
