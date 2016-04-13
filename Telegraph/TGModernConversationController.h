/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import "ASWatcher.h"

#import "TGMessageRange.h"

#import "TGModernConversationInputPanel.h"
#import "TGModernConversationEmptyListPlaceholderView.h"
#import "TGModernConversationCompanion.h"
#import "TGModernConversationInputTextPanel.h"
#import "TGAttachmentSheetWindow.h"
#import "TGModernMediaPickerController.h"
#import "TGAttachmentSheetRecentCameraView.h"
#import "GemsModernConversationInputTextPanel.h"

@class TGModernConversationCompanion;
@class TGModernViewStorage;
@class TGModernConversationItem;
@class TGUser;
@class TGMessage;
@class TGModernTemporaryView;

@class TGModernConversationTitlePanel;

@class TGModernViewInlineMediaContext;

@class TGBotReplyMarkup;

@class TGWebPageMediaAttachment;

GEMS_ADDED_PROPERTY // added forward declaration, i'm not sure what label should i use or don't use at all
@class TGSuggestionContext;
@class TGAttachmentCameraView;
@class TGMenuSheetController;
//GEMS_ADDED end

GEMS_CLASS_EXTERN //actually enum extern, for attachment menu
typedef enum {
    TGModernConversationActivityChangeAuto = 0,
    TGModernConversationActivityChangeActive = 1,
    TGModernConversationActivityChangeInactive = 2
} TGModernConversationActivityChange;


extern NSInteger TGModernConversationControllerUnloadHistoryLimit;
extern NSInteger TGModernConversationControllerUnloadHistoryThreshold;

#define migratedMessageIdOffset ((int32_t)1000000)

typedef enum {
    TGModernConversationInsertItemIntentGeneric = 0,
    TGModernConversationInsertItemIntentSendTextMessage = 1,
    TGModernConversationInsertItemIntentSendOtherMessage = 2,
    TGModernConversationInsertItemIntentLoadMoreMessagesAbove = 3,
    TGModernConversationInsertItemIntentLoadMoreMessagesBelow = 4
} TGModernConversationInsertItemIntent;

@interface TGModernConversationController : TGViewController <ASWatcher, TGModernConversationInputPanelDelegate>

@property (nonatomic, strong) ASHandle *actionHandle;

@property (nonatomic, strong) TGModernConversationCompanion *companion;
@property (nonatomic) bool shouldIgnoreAppearAnimationOnce;
@property (nonatomic) bool shouldOpenKeyboardOnce;

GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGModernConversationInputTextPanel *inputTextPanel;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGModernConversationInputPanel *currentInputPanel;
GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGModernConversationInputPanel *customInputPanel;

GEMS_PROPERTY_EXTERN @property (nonatomic, strong) TGAttachmentSheetWindow *attachmentSheetWindow;

GEMS_PROPERTY_EXTERN @property (nonatomic, weak) TGMenuSheetController * menuController;

GEMS_ADDED_PROPERTY @property(nonatomic) BOOL isSendCurrencyScreensOpen;

GEMS_METHOD_EXTERN
- (void)inputPanelRequestedSendMessage:(TGModernConversationInputTextPanel *)__unused inputTextPanel text:(NSString *)text;
//      ***** display attachment menu start
GEMS_METHOD_EXTERN - (void)inputPanelRequestedAttachmentsMenu:(TGModernConversationInputTextPanel *)__unused inputTextPanel;
//GEMS_METHOD_EXTERN - (void)_displayLegacyAttachmentsMenu;
//GEMS_METHOD_EXTERN - (void)_displayAttachmentsMenu;
GEMS_METHOD_EXTERN - (TGSuggestionContext *)_suggestionContext;
GEMS_METHOD_EXTERN - (void)_displayCameraWithView:(TGAttachmentCameraView *)cameraView menuController:(TGMenuSheetController *)menuController;
GEMS_METHOD_EXTERN - (void)_asyncProcessMediaAssetSignals:(NSArray *)signals forIntent:(TGModernMediaPickerControllerIntent)intent;
GEMS_METHOD_EXTERN - (void)_asyncProcessMediaAssetSignals:(NSArray *)signals;
GEMS_METHOD_EXTERN - (NSDictionary *)_descriptionForItem:(id)item caption:(NSString *)caption hash:(NSString *)hash;
GEMS_METHOD_EXTERN - (void)_displayMediaPicker:(bool)file fromFileMenu:(bool)fromFileMenu;
GEMS_METHOD_EXTERN - (void)_updateCanReadHistory:(TGModernConversationActivityChange)change;
GEMS_METHOD_EXTERN - (void)_displayFileMenuWithController:(TGMenuSheetController *)menuController;
//GEMS_METHOD_EXTERN - (void)_displayPhotoPicker;
//GEMS_METHOD_EXTERN - (void)_displayCameraWithView:(TGAttachmentSheetRecentCameraView *)cameraView;
//GEMS_METHOD_EXTERN - (void)_displayVideoPicker;
//GEMS_METHOD_EXTERN - (void)_displayWebImagePicker;
//GEMS_METHOD_EXTERN - (void)_displaySendFileMenu;
GEMS_METHOD_EXTERN - (void)_displayLocationPicker;
GEMS_METHOD_EXTERN - (void)_displayContactPicker;
//      ***** display attachment menu end

- (void)setInitialSnapshot:(CGImageRef)image backgroundView:(TGModernTemporaryView *)backgroundView viewStorage:(TGModernViewStorage *)viewStorage topEdge:(CGFloat)topEdge;
- (TGMessage *)latestVisibleMessage;
- (NSArray *)visibleMessageIds;
- (NSArray *)_currentItems;
- (void)replaceItems:(NSArray *)newItems messageIdForVisibleHoleDirection:(int32_t)messageIdForVisibleHoleDirection;
- (void)replaceItems:(NSArray *)newItems positionAtMessageId:(int32_t)positionAtMessageId expandAt:(int32_t)expandMessageId jump:(bool)jump top:(bool)top messageIdForVisibleHoleDirection:(int32_t)messageIdForVisibleHoleDirection scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated;
- (void)replaceItemsWithFastScroll:(NSArray *)newItems intent:(TGModernConversationInsertItemIntent)intent scrollToMessageId:(int32_t)scrollToMessageId scrollBackMessageId:(int32_t)scrollBackMessageId animated:(bool)animated;
- (void)replaceItems:(NSArray *)items atIndices:(NSIndexSet *)indices;
- (void)insertItems:(NSArray *)insertItems atIndices:(NSIndexSet *)indices animated:(bool)animated intent:(TGModernConversationInsertItemIntent)intent;
- (void)insertItems:(NSArray *)itemsArray atIndices:(NSIndexSet *)indexSet animated:(bool)animated intent:(TGModernConversationInsertItemIntent)intent removeAtIndices:(NSIndexSet *)removeIndexSet;
- (void)deleteItemsAtIndices:(NSIndexSet *)indices animated:(bool)animated;
- (void)_deleteItemsAtIndices:(NSIndexSet *)indices animated:(bool)animated animationFactor:(CGFloat)animationFactor;
- (void)moveItems:(NSArray *)moveIndexPairs;
- (void)updateItemAtIndex:(NSUInteger)index toItem:(TGModernConversationItem *)updatedItem delayAvailability:(bool)delayAvailability;
- (void)updateItemAtIndex:(NSUInteger)index toItem:(TGModernConversationItem *)updatedItem delayAvailability:(bool)delayAvailability animated:(bool)animated;
- (void)updateItemProgressAtIndex:(NSUInteger)index toProgress:(CGFloat)progress animated:(bool)animated;
- (void)imageDataInvalidated:(NSString *)imageUrl;
- (void)updateCheckedMessages;
- (void)updateMessageAttributes:(int32_t)messageId;
- (void)setHasUnseenMessagesBelow:(bool)hasUnseenMessagesBelow;
- (void)setUnreadMessageRangeIfAppropriate:(TGMessageRange)unreadMessageRange;

- (void)scrollToMessage:(int32_t)messageId sourceMessageId:(int32_t)sourceMessageId animated:(bool)animated;
- (void)openMediaFromMessage:(int32_t)messageId instant:(bool)instant;
- (void)closeMediaFromMessage:(int32_t)messageId instant:(bool)instant;
- (void)stopInlineMedia;
- (void)openBrowserFromMessage:(int32_t)messageId url:(NSString *)url;
- (void)showActionsMenuForUnsentMessage:(int32_t)messageId;
- (void)highlightAndShowActionsMenuForMessage:(int32_t)messageId;
- (void)temporaryHighlightMessage:(int32_t)messageId automatically:(bool)automatically;
- (void)showActionsMenuForLink:(NSString *)url webPage:(TGWebPageMediaAttachment *)webPage;
- (void)showActionsMenuForContact:(TGUser *)contact isContact:(bool)isContact;
- (void)showAddContactMenu:(TGUser *)contact;
- (void)showCallNumberMenu:(NSArray *)phoneNumbers;
- (void)enterEditingMode;
- (void)leaveEditingMode;
- (void)openKeyboard;
- (void)hideTitlePanel;

- (void)reloadBackground;
- (void)refreshMetrics;
- (void)setInputText:(NSString *)inputText replace:(bool)replace selectRange:(NSRange)selectRange;
- (void)setMessageEditingContext:(TGMessageEditingContext *)messageEditingContext;
- (NSString *)inputText;
- (void)updateWebpageLinks;
- (void)setReplyMessage:(TGMessage *)replyMessage animated:(bool)animated;
- (void)setForwardMessages:(NSArray *)forwardMessages animated:(bool)animated;
- (void)setInlineStickerList:(NSArray *)inlineStickerList;
- (void)setTitle:(NSString *)title;
- (void)setAvatarConversationId:(int64_t)conversationId title:(NSString *)title icon:(UIImage *)icon;
- (void)setAvatarConversationId:(int64_t)conversationId firstName:(NSString *)firstName lastName:(NSString *)lastName;
- (void)setTitleIcons:(NSArray *)titleIcons;
- (void)setTitleModalProgressStatus:(NSString *)titleModalProgressStatus;
- (void)setAvatarUrl:(NSString *)avatarUrl;
- (void)setStatus:(NSString *)status accentColored:(bool)accentColored allowAnimation:(bool)allowAnimation toggleMode:(TGModernConversationControllerTitleToggle)toggleMode;
- (void)setAttributedStatus:(NSAttributedString *)status allowAnimation:(bool)allowAnimation;
- (void)setTypingStatus:(NSString *)typingStatus activity:(int)activity;
- (void)setGlobalUnreadCount:(int)unreadCount;
- (void)setCustomInputPanel:(TGModernConversationInputPanel *)customInputPanel;
- (TGModernConversationInputPanel *)customInputPanel;
- (void)setPrimaryTitlePanel:(TGModernConversationTitlePanel *)titlePanel;
- (TGModernConversationTitlePanel *)primaryTitlePanel;
- (void)setSecondaryTitlePanel:(TGModernConversationTitlePanel *)secondaryTitlePanel;
- (void)setSecondaryTitlePanel:(TGModernConversationTitlePanel *)secondaryTitlePanel animated:(bool)animated;
- (TGModernConversationTitlePanel *)secondaryTitlePanel;
- (void)setEmptyListPlaceholder:(TGModernConversationEmptyListPlaceholderView *)emptyListPlaceholder;
- (void)setConversationHeader:(UIView *)conversationHeader;

- (void)setEnableAboveHistoryRequests:(bool)enableAboveHistoryRequests;
- (void)setEnableBelowHistoryRequests:(bool)enableBelowHistoryRequests;
- (void)setEnableUnloadHistoryRequests:(bool)enableUnloadHistoryRequests;
- (void)setEnableSendButton:(bool)enableSendButton;

- (bool)canReadHistory;

- (NSArray *)_items;
- (int32_t)_currentReplyMessageId;
- (NSArray *)_currentForwardMessageDescs;

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup;
- (void)appendCommand:(NSString *)command;
- (void)setHasBots:(bool)hasBots;
- (void)setCanBroadcast:(bool)canBroadcast;
- (void)setIsBroadcasting:(bool)isBroadcasting;
- (void)setIsAlwaysBroadcasting:(bool)isBroadcasting;
- (void)setInputDisabled:(bool)inputDisabled;
- (void)setIsChannel:(bool)isChannel;
- (void)updateControllerShouldHideInputTextByDefault;

- (void)openEmbed:(TGWebPageMediaAttachment *)webPage;

- (void)hideKeyboard;

- (void)activateSearch;
- (void)forwardMessages:(NSArray *)messageIds fastForward:(bool)fastForward;

- (void)setLoadingMessages:(bool)loadingMessages;
- (void)messagesDeleted:(NSArray *)messageIds;

@end
