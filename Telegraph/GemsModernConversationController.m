//
//  GemsModernConversationController.m
//  GetGems
//
//  Created by alon muroch on 3/20/15.
//
//

#import "GemsModernConversationController.h"
#import "GemsModernConversationInputTextPanel.h"
#import "TGGenericModernConversationCompanion.h"
#import "TGPrivateModernConversationCompanion.h"
#import "UserNotifications.h"
#import "TGGemsWallet.h"
#import "TGDatabase.h"
#import "TGAttachmentSheetButtonItemView.h"
#import "CurrencyExchangeProvider.h"
#import "ConversationMessageHandler.h"
#import "GemsAnalytics.h"
#import <pop/POP.h>
#import "GemsModernConversationControllerHelper.h"
#import "GemsModernConversationInviteFriendTitlePanel.h"
#import "ASWatcher.h"
#import "TGTelegraph.h"
#import "TGUser+Telegraph.h"
#import "TGUserDataRequestBuilder.h"
#import "TGImageUtils.h"
#import "GemsStringUtils.h"
#import "GemsNumberPadViewController.h"
#import "GemsTxConfirmationMessage.h"
#import "TGBroadcastModernConversationCompanion.h"
#import "TGSecretModernConversationCompanion.h"
#import "TGAppDelegate.h"
#import <GemsUI.h>
#import "PaymentRequestsContainer+TG.h"
#import "RandomGifHelper.h"
#import "TGGiphySearchResultItem.h"
#import "TGWebSearchGifItem.h"
#import "HPTextViewInternal.h"

#import "GroupPinCodeView.h"
#import "NSNumber+CD.h"

#import <objc/runtime.h>

#import "TGWebSearchController.h"

// GemsCore
#import <GemsLocalization.h>
#import <GemsCommons.h>

// GemsUI
#import <GemsAppearance.h>

@interface ConversationNumberPad()
{
    UIButton *_btnDivideBetweenGroup, *_btnSendEachInGroup;
    UIView *_groupBtnContainer, *_lineDivider;
}

@end
@implementation ConversationNumberPad

+ (instancetype)new
{
    return [[ConversationNumberPad alloc] initWithNibName:@"GemsNumberPadViewController" bundle:GemsUIBundle];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.prContainer.paymentContextType != PaymentRequestGroup)
    {
        // remove all bottom button targets
        [self.btnCopyAddress removeTarget:nil
                                   action:NULL
                         forControlEvents:UIControlEventAllEvents];
        // add a new target
        [self.btnCopyAddress addTarget:self action:@selector(sendForPrivateConversation) forControlEvents:UIControlEventTouchUpInside];
        
        [self.btnCopyAddress setTitle:GemsLocalized(@"GemsSend") forState:UIControlStateNormal];
        
        // GemsNumberPadController disables the copy button for when and address is choosen.
        // This will re-enable it.
        [self.btnCopyAddress setUserInteractionEnabled:YES];
    }
    else {
        self.btnCopyAddress.hidden = YES;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if(self.prContainer.paymentContextType == PaymentRequestGroup)
    {
        CGRect r = self.btnCopyAddress.frame;
        
        UIView *cont = [self groupButtonConainer];
        cont.frame = r;
        
        UIButton *btnDiv = [self btnDivideBetweenGroup];
        btnDiv.frame = CGRectMake(0, 0, r.size.width/2, r.size.height);
        
        UIButton *btnEach = [self btnSendEachInGroup];
        btnEach.frame = CGRectMake(r.size.width/2, 0, r.size.width/2, r.size.height);
        
        [self lineDivider].frame = CGRectMake(r.size.width/2, r.size.height * 0.15f, 1, r.size.height * 0.7f);
    }
}

- (void)sendByDividingAll
{
    PaymentRequestsContainer *newCont = [self containerForGroupPayment];
    newCont.paymentRequests = self.prContainer.paymentRequests;
    self.prContainer = newCont;
    
    for(PaymentRequest *pr in self.prContainer.paymentRequests) {
        if(self.initialCurrency == _G)
        {
            pr.outputAmount = (DigitalTokenAmount)([[self.rotatingValuesView getDigitalAssetValue] doubleValue] * GEM) / self.prContainer.paymentRequests.count;
        }
        else
        {
            pr.outputAmount = (DigitalTokenAmount)[[[self.rotatingValuesView getDigitalAssetValue] CD_sysUnitToSatoshi] doubleValue] / self.prContainer.paymentRequests.count;
        }
    }
    
    NSString *res = [self validateBeforeSending:self.prContainer];
    if(res.length > 0) {
        [UserNotifications showUserMessage:res];
        return;
    }
    else {
        
        [self.prContainer setGroupPinCodeType:GroupPinCodeDivide];
        
        [self send:self.prContainer];
    }
}

- (void)sendForEach
{
    PaymentRequestsContainer *newCont = [self containerForGroupPayment];
    newCont.paymentRequests = self.prContainer.paymentRequests;
    self.prContainer = newCont;
    
    for(PaymentRequest *pr in self.prContainer.paymentRequests) {
        if(self.initialCurrency == _G)
        {
            pr.outputAmount = (DigitalTokenAmount)([[self.rotatingValuesView getDigitalAssetValue] doubleValue] * GEM) ;
        }
        else
        {
            pr.outputAmount = (DigitalTokenAmount)[[[self.rotatingValuesView getDigitalAssetValue] CD_sysUnitToSatoshi] longLongValue];
        }
    }
    
    NSString *res = [self validateBeforeSending:self.prContainer];
    if(res.length > 0) {
        [UserNotifications showUserMessage:res];
        return;
    }
    else {
        [self.prContainer setGroupPinCodeType:GroupPinCodeEach];
        
        [self send:self.prContainer];
    }
}

- (void)sendForPrivateConversation
{
    PaymentRequest *pr = [self.prContainer.paymentRequests firstObject];
    if(self.initialCurrency == _G)
    {
        pr.outputAmount = (DigitalTokenAmount)([[self.rotatingValuesView getDigitalAssetValue] doubleValue] * GEM);
    }
    else
    {
        pr.outputAmount = (DigitalTokenAmount)[[[self.rotatingValuesView getDigitalAssetValue] CD_sysUnitToSatoshi] longLongValue];
    }
    
    NSString *res = [self validateBeforeSending:self.prContainer];
    if(res.length > 0) {
        [UserNotifications showUserMessage:res];
        return;
    }
    else {
        [self send:self.prContainer];
    }
}

- (PaymentRequestsContainer*)containerForGroupPayment
{
    PaymentRequestsContainer *ret = [PaymentRequestsContainer Factory_newGroupPayment];
    ret.currency = self.initialCurrency;
    if(self.initialCurrency == _G)
        ret.ledgerType = OffChainPayment;
    else
        ret.ledgerType = OnChainPayment;
    
    return ret;
}

#pragma mark - sending
-(NSString*)validateBeforeSending:(PaymentRequestsContainer*)prContainer
{
    GemsError *ret = [prContainer validatePaymentRequests];
    if(ret != nil)
        return ret.localizedError;
    
    // validate availble funds
    PaymentRequest *pr = [prContainer.paymentRequests firstObject];
    if(prContainer.currency == _G) {
        if([_G balance] < pr.outputAmount)
            return GemsLocalized(@"GemsBalanceTooLow");
    }
    else {
        if([_B balance] < pr.outputAmount)
            return GemsLocalized(@"GemsBalanceTooLow");
    }
    
    return @"";
}

-(void)send:(PaymentRequestsContainer*)prContainer
{
    if(self.completed)
        self.completed(prContainer, nil);
}

#pragma mark - screen orientation

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Group Buttons
- (UIView*)groupButtonConainer
{
    if(!_groupBtnContainer) {
        _groupBtnContainer = [UIView new];
        
        [self btnDivideBetweenGroup];
        [self btnSendEachInGroup];
        [self lineDivider];
        
        [self.view addSubview:_groupBtnContainer];
        
    }
    return _groupBtnContainer;
}

- (UIView *)lineDivider
{
    if(!_lineDivider) {
        _lineDivider = [[UIView alloc] init];
        _lineDivider.backgroundColor = self.btnCopyAddress.titleLabel.textColor;
        [_groupBtnContainer addSubview:_lineDivider];
    }
    return _lineDivider;
}

- (UIButton*)btnDivideBetweenGroup
{
    if(!_btnDivideBetweenGroup) {
        _btnDivideBetweenGroup = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnDivideBetweenGroup.enabled = YES;
        _btnDivideBetweenGroup.userInteractionEnabled = YES;
        _btnDivideBetweenGroup.titleLabel.font = self.btnCopyAddress.titleLabel.font;
        [_btnDivideBetweenGroup setTitle:GemsLocalized(@"Divide") forState:UIControlStateNormal];
        [_btnDivideBetweenGroup setTitleColor:self.btnCopyAddress.titleLabel.textColor forState:UIControlStateNormal];
        [_btnDivideBetweenGroup setBackgroundColor:self.btnCopyAddress.backgroundColor];
        [_btnDivideBetweenGroup addTarget:self action:@selector(sendByDividingAll) forControlEvents:UIControlEventTouchUpInside];
        [_groupBtnContainer addSubview:_btnDivideBetweenGroup];
    }
    return _btnDivideBetweenGroup;
}

- (UIButton*)btnSendEachInGroup
{
    if(!_btnSendEachInGroup) {
        _btnSendEachInGroup = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnSendEachInGroup.enabled = YES;
        _btnSendEachInGroup.userInteractionEnabled = YES;
        _btnSendEachInGroup.titleLabel.font = self.btnCopyAddress.titleLabel.font;
        [_btnSendEachInGroup setTitle:GemsLocalized(@"Each") forState:UIControlStateNormal];
        [_btnSendEachInGroup setTitleColor:self.btnCopyAddress.titleLabel.textColor forState:UIControlStateNormal];
        [_btnSendEachInGroup setBackgroundColor:self.btnCopyAddress.backgroundColor];
        [_btnSendEachInGroup addTarget:self action:@selector(sendForEach) forControlEvents:UIControlEventTouchUpInside];
        [_groupBtnContainer addSubview:_btnSendEachInGroup];
    }
    return _btnSendEachInGroup;
}

@end

//####################################

@interface GemsModernConversationController() <ASWatcher>
{
    int64_t _receiverID;
    int64_t _conversationID;
    
    TGUser *_user;
    NSString *_currentUserSearchPath;
    
    NSString *_message;
    
    BOOL didFinishTGUserSearch, didFetchConversationPeerData, didFetchReferralURL;
    GemsModernConversationControllerHelper *_helper;
}

@property(nonatomic, strong) NSArray *gemsUserIdsByTgId;
@property(nonatomic, strong) NSURL *referralURL;

@end

@implementation GemsModernConversationController

- (instancetype)initWithMessage:(NSString*)message
{
    self = [super init];
    if(self)
    {
        _message = message;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    {
        didFinishTGUserSearch = didFetchConversationPeerData = didFetchReferralURL = false;
    }
    
    _conversationID = ((TGGenericModernConversationCompanion*)self.companion).conversationId;
    
    if(![self.companion isMemberOfClass:[TGBroadcastModernConversationCompanion class]])
    {
        if(PrivateConversation(_conversationID)) {
            _receiverID = ((TGGenericModernConversationCompanion*)self.companion).conversationId;
            _user = [TGDatabaseInstance() loadUser:_receiverID];
        }
        else if (SecretConversation(_conversationID)) {
            _receiverID = ((TGSecretModernConversationCompanion*)self.companion).uid;
            _user = [TGDatabaseInstance() loadUser:-_receiverID];
        }
        
        /**
         In case we send an unsolicited msg, we need to fetch the accessHash to send messages (only for private and secret personal chat)
         */
        if(_user.phoneNumberHash == 0 && !GroupConversation(_conversationID)) {
            NSString *searchStr = _user.userName;
            [TGTelegraphInstance doSearchContactsByName:searchStr limit:1 completion:^(TLcontacts_Found *result)
             {
                 didFinishTGUserSearch = YES;
                 if (result != nil)
                 {
                     _user = [[TGUser alloc] initWithTelegraphUserDesc:[result.users firstObject]];
                     NSArray *users = @[_user];
                     [TGUserDataRequestBuilder executeUserObjectsUpdate:users];
                 }
             }];
        }
        else {
            didFinishTGUserSearch = YES;
        }
        
        _helper = [[GemsModernConversationControllerHelper alloc] initWithConversationID:_conversationID conversationController:self];
        
        //load conversation data from defaults
        _gemsUserIdsByTgId = [_helper fetchStoredConversationData];
        if(_gemsUserIdsByTgId.count > 0)
            didFetchConversationPeerData = YES;
        
        // refresh conversation data
        [_helper fetchConversationDataFromServerCompletion:^(NSArray *gemsUserIdsByTgId, NSString *error) {
            if(error) {
                didFetchConversationPeerData = NO;
                return ;
            }
            didFetchConversationPeerData = YES;
            
            _gemsUserIdsByTgId = gemsUserIdsByTgId;
            
            // show non gems invite drop down
            if(!GroupConversation(_conversationID))
                if(!_gemsUserIdsByTgId && [GemsModernConversationInviteFriendTitlePanel enoughTimePassedSinceLastShowedPanelForUser:_conversationID]) {
                    GemsModernConversationInviteFriendTitlePanel *panel = [[GemsModernConversationInviteFriendTitlePanel alloc] initWithFrame:self.view.frame conversationId:_conversationID];
                    panel.close = ^{ [self closeInviteFriendTitlePanel]; };
                    panel.action = ^ { [self inviteFriendFromTitlePanel]; };
                    [self setSecondaryTitlePanel:panel animated:YES];
                }
        }];
        [_helper fetchReferralURLCompletion:^(NSURL *referralURL, NSString *error) {
           _referralURL = referralURL;
            didFetchReferralURL = YES;
        }];

    }
    
    if(_message)
        self.inputTextPanel.inputField.text = _message;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)readyAfterPeerDataFetching
{
    return didFinishTGUserSearch && didFetchConversationPeerData && didFetchReferralURL;
}

- (NSString*)findGemsIdByTGId:(int32_t)tgid
{
    for(NSDictionary *d in _gemsUserIdsByTgId)
    {
        if([d[@"telegramUserId"] intValue] == tgid)
            return d[@"userId"];
    }
    
    return nil;
}

- (NSString*)btcAddressByTgId:(int32_t)tgid
{
    for(NSDictionary *d in _gemsUserIdsByTgId)
    {
        if([d[@"telegramUserId"] intValue] == tgid) {
            NSString *btcAdd = d[@"btcAddress"];
            return btcAdd.length > 0? btcAdd:nil;
        }
    }
    
    return nil;
}

#pragma mark - invite friend title panel

- (void)closeInviteFriendTitlePanel
{
    [self setSecondaryTitlePanel:nil animated:YES];
}

- (void)inviteFriendFromTitlePanel
{
    
    NSString *msg = _R(GemsLocalized(@"InviteTextViaTelegram"), @"%1$s", _referralURL.absoluteString);
    [super inputPanelRequestedSendMessage:self.inputTextPanel text:msg];
    [self closeInviteFriendTitlePanel];
}

#pragma mark - input panel delegate

- (void)inputPanelTextRandomGifPressed:(GemsModernConversationInputTextPanel *)inputTextPanel
{
    NSString *txt = [NSString stringWithFormat:@"%@ ", [inputTextPanel.inputField.text Conversation_addGifSymbol]];
    [inputTextPanel setText:txt animated:YES];
    [inputTextPanel.inputField becomeFirstResponder];
}

- (void)inputPanelRequestedSendMessage:(GemsModernConversationInputTextPanel *) inputTextPanel text:(NSString *)__unused text
{
    // normal text msg
    if(!inputTextPanel.prContainer)
    {
        // Random gif request
        if([inputTextPanel.inputField.text Conversation_randomGifRequest])
        {
            [self handleRandomGifRequest:inputTextPanel];
            if(didFetchReferralURL)
                [super inputPanelRequestedSendMessage:inputTextPanel text:[RandomGifHelper wrapRandomGifMessage:text referralURL:_referralURL.absoluteString]];
            else
                [super inputPanelRequestedSendMessage:inputTextPanel text:[RandomGifHelper wrapRandomGifMessage:text referralURL:GEMS_WEBSITE_URL]];
        }
        else {
            [super inputPanelRequestedSendMessage:inputTextPanel text:text];
        }
        return;

    }
    
    // a payment request but make sure we downloaded the necessary data
    if(![self readyAfterPeerDataFetching]) {
        [UserNotifications showUserMessage:GemsLocalized(@"GemsErrorFetchingPayeeData")];
        return;
    }
    else
        [self handleConversationPayment:inputTextPanel];
}

- (void)handleConversationPayment:(GemsModernConversationInputTextPanel *) inputTextPanel {
    PaymentRequestsContainer *prr = inputTextPanel.prContainer;
    
    [inputTextPanel.inputField resignFirstResponder];
    
    if(!GroupConversation(_conversationID)) // private and secret chats
    {
        TGUser *user = [TGDatabaseInstance() loadUser:_receiverID];
        PaymentRequest *pr = [inputTextPanel.prContainer.paymentRequests firstObject];
        NSString *gemsId = [self findGemsIdByTGId:_receiverID];
        NSString *payeeAddress = [self btcAddressByTgId:_receiverID];
        
        /*
         payee is not a gems user
         */
        if(!gemsId) {
            NSString *amountStr, *unit;
            if(inputTextPanel.prContainer.currency == _B) {
                amountStr = formatDoubleToStringWithDecimalPrecision([[@(pr.outputAmount) CD_satoshiToSysUnit] doubleValue], sysDecimalPrecisionForUI(inputTextPanel.prContainer.currency));
                unit = [GemsStringUtils btcSysUnitName];
            }
            else {
                amountStr = formatDoubleToStringWithDecimalPrecision([[@(pr.outputAmount) currency_gillosToGems] doubleValue], sysDecimalPrecisionForUI(inputTextPanel.prContainer.currency));
                unit = @"Gems";
            }
            NSString *fiatAmount = @"";
            
            NSString *msgForNonGemsUser = [ConversationMessageHandler msgForNonGemsUser:_referralURL.absoluteString digitalCurrencyDisplayName:unit digitalCurrencyAmount:amountStr fiatCurrencyValue:fiatAmount];
            [super inputPanelRequestedSendMessage:inputTextPanel text:msgForNonGemsUser];
            
            // notify user that he sent gems to a non Gems user.
            NSString *notAGemsUserNotif = [GemsLocalized(@"GemsInviteBannerTitle") stringByReplacingOccurrencesOfString:@"%1$s" withString:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
            [UserNotifications showUserMessage:notAGemsUserNotif];
            return;
        }
        
        if(prr.currency == _B && !payeeAddress)
        {
            [UserNotifications showUserMessage:GemsLocalized(@"NoBitcoinAddressForUserText")];
            return;
        }
        
        if(prr.currency == _B)
            pr.paymentAddress = payeeAddress;
        pr.receiverTelegramID = _receiverID;
        pr.conversationID = _conversationID;
        pr.receiverGemsID = gemsId;
        inputTextPanel.prContainer.includeNetworkFee = inputTextPanel.prContainer.currency == _B;
        
        [_helper sendPersonalPaymentRequest:inputTextPanel.prContainer referralURL:_referralURL];
        
    }
    else if(GroupConversation(_conversationID)) // group chats
    {
        inputTextPanel.prContainer = [self verifyAndCompletePayReqForGroups:inputTextPanel.prContainer];
        if(inputTextPanel.prContainer.paymentRequests.count == 0)
        {
            [UserNotifications showUserMessage:GemsLocalized(@"GemsNonOfThePayeesAreGemsMembers")];
            return;
        }
        
        if([inputTextPanel.prContainer paymentContextType] == PaymentRequestTipping)
            [_helper sendTippingInGroupPaymentRequest:inputTextPanel.prContainer referralURL:_referralURL];
        else
            [_helper sendGroupPaymentRequests:inputTextPanel.prContainer referralURL:_referralURL];
    }
}

- (void)handleRandomGifRequest:(GemsModernConversationInputTextPanel *) inputTextPanel
{
    NSString *category = [inputTextPanel.inputField.text Conversation_randomGifCategory];
    if(category) {
        
        TGWebSearchController *searchController = [[TGWebSearchController alloc] init];
        __weak TGModernConversationController *weakSelf = self;
        searchController.completion = ^(TGWebSearchController *sender)
        {
            NSArray *items = [TGWebSearchController recentSelectedItems];
            __strong TGModernConversationController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                NSMutableArray *imageDescriptions = [[NSMutableArray alloc] init];
                
                for (id item in items)
                {
                    if ([item isKindOfClass:[TGGiphySearchResultItem class]])
                    {
                        id documentDescription = [strongSelf.companion documentDescriptionFromGiphySearchResult:item];
                        if (documentDescription != nil)
                            [imageDescriptions addObject:documentDescription];
                    }
                }
                
                if (imageDescriptions.count != 0)
                    [strongSelf.companion controllerWantsToSendImagesWithDescriptions:imageDescriptions asReplyToMessageId:0];
            }
        };
        
        // simulate web search controller
        [searchController viewDidLoad];
        [searchController viewWillAppear:NO];
        [searchController viewDidAppear:NO];
        searchController.searchBar.selectedScopeButtonIndex = 1;
        searchController.didFinishSearchingGifs = ^(NSArray *results) {
            NSMutableArray *gifObjs = [NSMutableArray new];
            for(id obj in results) {
                if([obj isKindOfClass:[TGWebSearchGifItem class]])
                    [gifObjs addObject:obj];
            }
            if(gifObjs.count == 0)
            {
                GemsModernConversationInputTextPanel *input = [GemsModernConversationInputTextPanel new];
                NSString *txt = [NSString stringWithFormat:@"%@ cat", [inputTextPanel.inputField.text Conversation_addGifSymbol]];
                [input setText:txt animated:NO];
                [self handleRandomGifRequest:input];
                return ;
            }
            
            int i = arc4random() % gifObjs.count;
            searchController.selectedGifItems = @[gifObjs[i]];
            [searchController doneButtonPressed];
        };
        searchController.searchBar.text = category;
        [searchController searchBarSearchButtonClicked:searchController.searchBar];
    }
}

- (PaymentRequestsContainer*)verifyAndCompletePayReqForGroups:(PaymentRequestsContainer*)container
{
    // validate all payees
    NSMutableArray *reqForRemoval = [[NSMutableArray alloc] init];
    for(PaymentRequest *pr in container.paymentRequests)
    {
        // if req only has tg username
        if(pr.receiverTelegramUsername)
        {
            TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:_conversationID];
            for(NSNumber *uid in conversation.chatParticipants.chatParticipantUids)
            {
                TGUser *u = [TGDatabaseInstance() loadUser:[uid int32Value]];
                if([u.userName isEqualToString:pr.receiverTelegramUsername])
                {
                    NSString *gemsId = [self findGemsIdByTGId:u.uid];
                    NSString *payeeAddress = [self btcAddressByTgId:u.uid];
                    
                    if(!gemsId || (container.currency == _B && !payeeAddress))
                    {
                        [reqForRemoval addObject:pr];
                    }
                    else
                    {
                        pr.receiverTelegramID = u.uid;
                        pr.receiverGemsID = gemsId;
                        pr.paymentAddress = [self btcAddressByTgId:u.uid];
                    }
                    continue;
                }
            }
        }
        
        // if req has only tg id
        if(pr.receiverTelegramID != kPaymentRequestDefaultTgId && !pr.receiverGemsID)
        {
            NSString *gemsId = [self findGemsIdByTGId:pr.receiverTelegramID];
            if(!gemsId)
            {
                [reqForRemoval addObject:pr];
            }
            else
            {
                pr.receiverGemsID = gemsId;
            }
            continue;
        }
    }
    
    [container.paymentRequests removeObjectsInArray:reqForRemoval];
    return container;
}

#pragma mark - send bitcoins and gems callbacks
ConversationNumberPad *visibleNumPadView;
- (void)sendBitcoinsPressed:(GemsModernConversationInputTextPanel *)inputTextPanel
             paymentContext:(PaymentRequestContext)context
                 forUserIds:(NSArray*)tgids
{
    if(visibleNumPadView) return;
    
    PaymentRequestsContainer *prContainer = [[PaymentRequestsContainer alloc] initWithContextType:context];
    prContainer.includeNetworkFee = YES;
    prContainer.currency = _B;
    prContainer.ledgerType = OnChainPayment;
    
    for(NSNumber *uid in tgids)
    {
        if([uid int64Value] == TGTelegraphInstance.clientUserId) continue;
        
        PaymentRequest *pr = [[PaymentRequest alloc] init];
        pr.receiverTelegramID = [uid int64Value];
        pr.paymentAddress = [self btcAddressByTgId:[uid int32Value]];
        if(!pr.paymentAddress || ![_B validateAddress:pr.paymentAddress]) continue;
        
        pr.outputAmount = 0;
        [prContainer.paymentRequests addObject:pr];
    }
    
    if(prContainer.paymentRequests.count == 0) {
        
        if(tgids.count == 1) // single user
        {
            TGUser *user = [TGDatabaseInstance() loadUser:[tgids[0] int64Value]];
            NSString *notAGemsUserNotif = [GemsLocalized(@"GemsInviteBannerTitle") stringByReplacingOccurrencesOfString:@"%1$s" withString:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
            [UserNotifications showUserMessage:notAGemsUserNotif];
        }
        else if(tgids.count > 1) { // group
            [UserNotifications showUserMessage:GemsLocalized(@"GemsNonOfThePayeesAreGemsMembers")];
        }
        
        return;
    }
    
    PaymentRequestContext t;
    if(tgids.count > 1)
        t = PaymentRequestGroup;
    else {
        if(!GroupConversation(_conversationID)) // private and secret chats
            t = PaymentRequestSingle;
        else
            t = PaymentRequestTipping;
    }
    [self loadNumPadController:inputTextPanel andPaymentRequests:prContainer];
}

- (void)sendGemsPressed:(GemsModernConversationInputTextPanel *)inputTextPanel
         paymentContext:(PaymentRequestContext)context
             forUserIds:(NSArray*)tgids
{
    if(visibleNumPadView) return;

    PaymentRequestsContainer *prContainer = [[PaymentRequestsContainer alloc] initWithContextType:context];
    prContainer.includeNetworkFee = NO;
    prContainer.currency = _G;
    prContainer.ledgerType = OffChainPayment;
    
    for(NSNumber *uid in tgids)
    {
        if([uid int64Value] == TGTelegraphInstance.clientUserId) continue;
        
        NSString *receiverGemsId = [self findGemsIdByTGId:[uid int64Value]];
        if(receiverGemsId)
        {
            PaymentRequest *pr = [[PaymentRequest alloc] init];
            pr.receiverTelegramID = [uid int64Value];
            pr.receiverGemsID = receiverGemsId;
            pr.outputAmount = 0;
            [prContainer.paymentRequests addObject:pr];
        }
    }

    if(prContainer.paymentRequests.count == 0) {
        
        if(tgids.count == 1) // single user or tipping
        {
            TGUser *user = [TGDatabaseInstance() loadUser:[tgids[0] int64Value]];
            NSString *notAGemsUserNotif = [GemsLocalized(@"GemsInviteBannerTitle") stringByReplacingOccurrencesOfString:@"%1$s" withString:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
            [UserNotifications showUserMessage:notAGemsUserNotif];
        }
        else if(tgids.count > 1) { // group
            [UserNotifications showUserMessage:GemsLocalized(@"GemsNonOfThePayeesAreGemsMembers")];
        }
        
        return;
    }
    
    [self loadNumPadController:inputTextPanel andPaymentRequests:prContainer];
}

-(void)loadNumPadController:(GemsModernConversationInputTextPanel *)inputTextPanel andPaymentRequests:(PaymentRequestsContainer*)prContainer
{
    visibleNumPadView = [ConversationNumberPad new];
    visibleNumPadView.closePressed = ^{
//        TGAppDelegateInstance.tabletMainViewController.detailViewController = nil;
    };
    
    visibleNumPadView.initialCurrency = prContainer.currency;
    if(prContainer.currency == _G) // off chain conversation txs do no require fee
        visibleNumPadView.includeFees = NO;
    visibleNumPadView.prContainer = prContainer;
    
    visibleNumPadView.completed = ^(PaymentRequestsContainer *prContainer, NSString *errorString)
    {
        if(errorString)
        {
            [UserNotifications showUserMessage:errorString];
            return ;
        }
        
        PaymentRequest *pr = [prContainer.paymentRequests firstObject];
        NSNumber *n = [NSNumber numberWithLongLong:pr.outputAmount];
        double amount = (prContainer.currency == _G)? [[n currency_gillosToGems] doubleValue]:[[n CD_satoshiToSysUnit] doubleValue];
        
        // simulate a user send msg, e.g., "1 gem"
        NSString *newMsg = [NSString stringWithFormat:@"%g %@", amount, [prContainer.currency symbol]];
        inputTextPanel.prContainer = prContainer;
        [self inputPanelRequestedSendMessage:inputTextPanel text:newMsg];
        
        [self animateViewDismiss:visibleNumPadView]; // close
    };
    
    __weak typeof(ConversationNumberPad) *weakConversationNumberPad = visibleNumPadView;
    visibleNumPadView.dismissBlock = ^()
    {
        __strong typeof(ConversationNumberPad) *strongSelf = weakConversationNumberPad;
        if(strongSelf)
            [self animateViewDismiss:strongSelf];
    };
    
    // animate
    [self animateViewPop:visibleNumPadView];

}

UIBarButtonItem *previousLeftNavItem;
- (void)animateViewPop:(UIViewController*)v
{
    // make sure no keyboard is showing
    [self.inputTextPanel.inputField resignFirstResponder];
    
    // set nav button
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:GemsLocalized(@"Common.Close") style:UIBarButtonItemStyleDone target:self
                                                                  action:@selector(closePopNumPad:)];
    previousLeftNavItem = self._currentNavigationItem.leftBarButtonItem;
    [self setLeftBarButtonItem:backButton];
    
    CGPoint p = CGPointMake(0, -self.view.frame.size.height);
    CGSize s = self.view.frame.size;
    v.view.frame = (CGRect){p,s};
    v.view.tag = 2000;
    [self.view addSubview:v.view];
    
//    [v viewDidLoad];
    [v viewWillAppear:NO];
    v.view.alpha = 1.0f;
    [v viewDidAppear:NO];
    
    [UIView animateWithDuration:0.7f delay:0.2f usingSpringWithDamping:0.5f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        v.view.center = self.view.center;
    } completion:^(BOOL finished) {
        self.isSendCurrencyScreensOpen = YES;
    }];
}

- (void)animateViewDismiss:(UIViewController*)v
{
    CGPoint p = self.view.center;
    p.y -= self.view.frame.size.height;
    
    [v viewWillAppear:NO];
    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        v.view.center = p;
    } completion:^(BOOL __unused finished) {
        [v.view removeFromSuperview];
        [v viewDidDisappear:NO];
        
        // set nav button
        [self setLeftBarButtonItem:previousLeftNavItem];
        visibleNumPadView = nil;
    }];
}

-(void) closePopNumPad:(id)sender {
    
    if(visibleNumPadView.dismissBlock)
        visibleNumPadView.dismissBlock();
    
    self.isSendCurrencyScreensOpen = NO;
}

#pragma mark - screen orientation

- (BOOL)shouldAutorotate
{
    if(visibleNumPadView)
        return NO;
    return YES;
}

@end
