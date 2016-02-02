//
//  GemsModernConversationControllerHelper.m
//  GetGems
//
//  Created by alon muroch on 4/7/15.
//
//

#import "GemsModernConversationControllerHelper.h"
#import <Branch/Branch.h>
#import "TGConversation.h"
#import "TGDatabase.h"
#import "GemsModernConversationInputTextPanel.h"
#import "TGGemsWallet.h"
#import "ConversationMessageHandler.h"

// GemsCore
#import <GemsCore/GemsCD.h>
#import <GemsCore/PaymentRequest.h>
#import <GemsCore/GemsStringUtils.h>
#import <GemsCore/GemsAnalytics.h>
#import <GemsCore/NSURL+GemsReferrals.h>

// GemsUI
#import <GemsUI/UserNotifications.h>
#import <GemsUI/GemsTxConfirmationMessage.h>

// Networking
#import <GemsNetworking/GemsNetworking.h>

@interface GemsModernConversationControllerHelper()
{
    __weak GemsModernConversationController *_controller;
    
    TGConversation *_conversation;
    NSArray *_participants;
    
    GroupPinCodeView *_groupPincodeView;
    SinglePinCodeView *_singlePincodeView;
    
    BOOL _didRequestDataFetching;
    BOOL _readyToFetchData;
    
    void(^_conversationDataFetchCompletion)(NSArray *gemsUserIdsByTgId, NSString *error);
}

@end

@implementation GemsModernConversationControllerHelper

- (instancetype)initWithConversationID:(int64_t)conversationID conversationController:(GemsModernConversationController*)controller
{
    self = [super init];
    if(self) {
        _controller = controller;
        
        static dispatch_queue_t queue;
        if(!queue)
            queue = dispatch_queue_create("conversation_data_fetching_queue",NULL);
        
        _conversation = [TGDatabaseInstance() loadConversationWithId:conversationID];
        if(_conversation.chatParticipantCount == 0) { // private
            if(PrivateConversation(conversationID))
                _participants = @[@(conversationID)];
            if(SecretConversation(conversationID)) {
                _participants = _conversation.chatParticipants.chatParticipantUids;
            }
            _readyToFetchData = YES;
        }
        else {
            _participants = _conversation.chatParticipants.chatParticipantUids;
            if(_participants.count != _conversation.chatParticipantCount) {
                /**
                 Modern conversation companion fetches group participants data
                 on viewDidApear:. If the number of participants doesn't match their data count we wait for
                 the fetching operation to end and only then we execute this fetching operation (if requested previously)
                 */
                NSLog(@"Waiting to get conversation %lld data", conversationID);
                dispatch_async(queue, ^{
                    while (!_readyToFetchData) {
                        [NSThread sleepForTimeInterval:0.03f];
                        
                        _conversation = [TGDatabaseInstance() loadConversationWithId:conversationID];
                        _participants = _conversation.chatParticipants.chatParticipantUids;
                        if(_participants.count == _conversation.chatParticipantCount)
                            _readyToFetchData = YES;
                        
                        if(_readyToFetchData) {
                            NSLog(@"Received conversation %lld data, fetching Gems conversation data", conversationID);
                            [self fetchConversationDataFromServerCompletion:_conversationDataFetchCompletion];
                        }
                    }
                });
            }
            else
                _readyToFetchData = YES;
        }
    }
    return self;
}

- (void)fetchConversationDataFromServerCompletion:(void(^)(NSArray *gemsUserIdsByTgId, NSString *error))completion
{
    _didRequestDataFetching = YES;
    if(!_readyToFetchData) {
        _conversationDataFetchCompletion = completion;
        return;
    }
    
    NSLog(@"Fetching gems user data for conversation %@", _participants);
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(NSNumber *tgid in _participants)
    {
        [arr addObject:@{@"telegramUserId" : tgid}];
    }
    
    [API getGemsUserInfoByTelegramIds:arr respond:^(GemsNetworkRespond *respond) {
        if([respond hasError]) {
            if(completion)
                completion(nil, respond.error.localizedError);
        }
        else {
            NSArray *results = (NSArray*)respond.rawResponse[@"records"];
            if(results.count == 0) {
                results = nil;
            }
            else {
                [[NSUserDefaults standardUserDefaults] setObject:results forKey:[@(_conversation.conversationId) stringValue]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            if(completion)
                completion(results, nil);
        }
    }];
}

- (void)fetchReferralURLCompletion:(void(^)(NSURL *referralURL, NSString *error))completion
{
    NSLog(@"Fetching referral url");
    [NSURL urlWithMyUniqueReferralLinkCompletion:^(NSURL *url, NSError *error) {
        if(error) {
            if(completion)
                completion(nil, error.localizedDescription);
            return ;
        }
        
        if(completion)
            completion(url, nil);
    }];
}

- (NSArray *)fetchStoredConversationData
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:[@(_conversation.conversationId) stringValue]];
}

#pragma mark - sending

- (void)sendGroupPaymentRequests:(PaymentRequestsContainer*)prContainer referralURL:(NSURL*)referralURL
{
    GemsModernConversationInputTextPanel *inputTextPanel = _controller.inputTextPanel;
    
    GroupPinCodeType verificationType = [inputTextPanel.prContainer groupPinCodeType];
    
    // check validity
    NSString *error = [self validatepaymentReq:inputTextPanel.prContainer];
    if(error) {
        [UserNotifications showUserMessage:error];
        return;
    }
    
    [WALLET sendWithPaymentRequests:inputTextPanel.prContainer authenticate:YES completion:^(bool result, NSString *error) {
        if(result)
        {
            ////////////////////////////
            //
            // send
            //
            ////////////////////////////
            /**
             Generate the text message to send
             */
            // asset denomination
            NSString *assetDeno;
            NSString *amountStr;
            DigitalTokenAmount amount = ((PaymentRequest*)[prContainer.paymentRequests firstObject]).outputAmount;
            NSUInteger precision = sysDecimalPrecisionForUI(prContainer.currency);
            if(prContainer.currency == _B) {
                assetDeno = [GemsStringUtils btcSysUnitName];
                amountStr = formatDoubleToStringWithDecimalPrecision([[@(amount) CD_satoshiToSysUnit] doubleValue], precision);
            }
            else {
                assetDeno = [[_G symbol] uppercaseString];
                amountStr = formatDoubleToStringWithDecimalPrecision([[@(amount) currency_gillosToGems] doubleValue], precision);
            }
            
            // payees names
            NSMutableArray *names = [[NSMutableArray alloc] init];
            for(PaymentRequest *pr in prContainer.paymentRequests)
            {
                TGUser *tgUser = [TGDatabaseInstance() loadUser:pr.receiverTelegramID];
                if(tgUser.userName)
                    [names addObject:[NSString stringWithFormat:@"@%@", tgUser.userName]];
                else
                    [names addObject:[NSString stringWithFormat:@"%@ %@", tgUser.firstName, tgUser.lastName]];
            }
            
            
            // generate confirmation text
            GemsTxConfirmationMessage *confirmMsg = [inputTextPanel.prContainer confirmationMessageWithNameFetcher:^NSString *(PaymentRequest *pr) {
                TGUser *user = [TGDatabaseInstance() loadUser:pr.receiverTelegramID];
                return [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
            }];
            ////////////////////////////
            //
            // send messaget to conversation
            //
            ////////////////////////////
            NSString *msgForGroup;
            if(names.count > 1)
                msgForGroup = [ConversationMessageHandler msgForGroup:referralURL.absoluteString digitalCurrencyDisplayName:assetDeno digitalCurrencyAmount:amountStr fiatCurrencyValue:@"" userNames:names];
            else
                msgForGroup =[ConversationMessageHandler msgForTipping:referralURL.absoluteString digitalCurrencyDisplayName:assetDeno digitalCurrencyAmount:confirmMsg.digitalTokenAmountStr fiatCurrencyValue:@"" userNames:names];
            
            [self trackSuccessForAnalytics:inputTextPanel.prContainer];
            
            inputTextPanel.prContainer = nil; // so it will send the message
            [_controller inputPanelRequestedSendMessage:inputTextPanel text:msgForGroup];
        }
        else {
            if(error) { // if error is nil we assume its the user just canceled the payment
                [UserNotifications showUserMessage:error];
                [self trackFaieldForAnalytics:inputTextPanel.prContainer error:error];
            }
        }
    }];
}

- (void)sendTippingInGroupPaymentRequest:(PaymentRequestsContainer*)prContainer referralURL:(NSURL*)referralURL
{
    [self sendSinglePaymentRequest:prContainer tipping:YES referralURL:referralURL];
}

- (void)sendPersonalPaymentRequest:(PaymentRequestsContainer*)prContainer referralURL:(NSURL*)referralURL
{
    [self sendSinglePaymentRequest:prContainer tipping:NO referralURL:referralURL];
}

- (void)sendSinglePaymentRequest:(PaymentRequestsContainer*)prContainer tipping:(BOOL)isTipping referralURL:(NSURL*)referralURL
{
    GemsModernConversationInputTextPanel *inputTextPanel = _controller.inputTextPanel;
    PaymentRequest *pr = [prContainer.paymentRequests firstObject];
    TGUser *tgUser = [TGDatabaseInstance() loadUser:pr.receiverTelegramID];
    
    // check validity
    NSString *error = [self validatepaymentReq:inputTextPanel.prContainer];
    if(error) {
        [UserNotifications showUserMessage:error];
        return;
    }
    
    // generate confirmation text
    GemsTxConfirmationMessage *confirmMsg = [inputTextPanel.prContainer confirmationMessageWithNameFetcher:^NSString *(PaymentRequest *pr) {
        TGUser *user = [TGDatabaseInstance() loadUser:pr.receiverTelegramID];
        return [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    }];
    
    // asset denomination
    NSString *assetDeno;
    if(prContainer.currency == _B)
        assetDeno = [GemsStringUtils btcSysUnitName];
    else
        assetDeno = [_G symbol];
    
    if(!pr.receiverGemsID) {
        NSString *msgForNonGemsUser = [ConversationMessageHandler msgForNonGemsUser:referralURL.absoluteString digitalCurrencyDisplayName:assetDeno digitalCurrencyAmount:confirmMsg.digitalTokenAmountStr fiatCurrencyValue:confirmMsg.fiatAmountStr];
        
        inputTextPanel.prContainer = nil; // so it will send the message
        [_controller inputPanelRequestedSendMessage:inputTextPanel text:msgForNonGemsUser];
        
        // notify user that he sent gems to a non Gems user.
        NSString *notAGemsUserNotif = [GemsLocalized(@"GemsInviteBannerTitle") stringByReplacingOccurrencesOfString:@"%1$s" withString:[NSString stringWithFormat:@"%@ %@", tgUser.firstName, tgUser.lastName]];
        [UserNotifications showUserMessage:notAGemsUserNotif];
    }
    else {
        [WALLET sendWithPaymentRequests:inputTextPanel.prContainer authenticate:YES completion:^(bool result, NSString *error) {
            if(result)
            {
                ////////////////////////////
                //
                // send messaget to conversation
                //
                ////////////////////////////
                NSString *msgForGemsuser;
                NSString *fiatStr = (prContainer.currency == _B && confirmMsg.fiatAmountStr.length > 0) ? ([NSString stringWithFormat:@"(%@)", confirmMsg.fiatAmountStr]):(@"");
                if(isTipping)
                {
                    // payees names
                    NSMutableArray *names = [[NSMutableArray alloc] init];
                    for(PaymentRequest *pr in prContainer.paymentRequests)
                    {
                        TGUser *tgUser = [TGDatabaseInstance() loadUser:pr.receiverTelegramID];
                        if(tgUser.userName)
                            [names addObject:[NSString stringWithFormat:@"@%@", tgUser.userName]];
                        else
                            [names addObject:[NSString stringWithFormat:@"%@ %@", tgUser.firstName, tgUser.lastName]];
                    }
                    msgForGemsuser = [ConversationMessageHandler msgForTipping:referralURL.absoluteString digitalCurrencyDisplayName:assetDeno digitalCurrencyAmount:confirmMsg.digitalTokenAmountStr fiatCurrencyValue:fiatStr userNames:names];
                }
                else {
                    msgForGemsuser = [ConversationMessageHandler msgForGemsUser:referralURL.absoluteString digitalCurrencyDisplayName:assetDeno digitalCurrencyAmount:confirmMsg.digitalTokenAmountStr fiatCurrencyValue:fiatStr];
                }
                
                [self trackSuccessForAnalytics:inputTextPanel.prContainer];
                
                inputTextPanel.prContainer = nil; // so it will send the message
                [_controller inputPanelRequestedSendMessage:inputTextPanel text:msgForGemsuser];
            }
            else {
                if(error) { // if error is nil we assume its the user just canceled the payment
                    [UserNotifications showUserMessage:error];
                    [self trackFaieldForAnalytics:inputTextPanel.prContainer error:error];
                }
            }
        }];
    }
}

- (NSString*)validatepaymentReq:(PaymentRequestsContainer *)prContainer
{
    GemsError *error = [prContainer validatePaymentRequests];
    if(error)
        return error.localizedError;
    
    for(PaymentRequest *pr in prContainer.paymentRequests)
        if(pr.receiverTelegramID == kPaymentRequestDefaultTgId || !pr.receiverGemsID)
            return @"Not all members are Gems users";
    
    
    // check sufficient funds
    if(prContainer.currency == _B && [_B balance] <= [prContainer totalAmount]) {
        return GemsLocalized(@"GemsBalanceTooLow");
    }
    
    if(prContainer.currency == _G && [_G balance] < [prContainer totalAmount]) {
        return GemsLocalized(@"GemsBalanceTooLow");
    }
    
    return nil;
}

#pragma mark - analytics

- (void)trackSuccessForAnalytics:(PaymentRequestsContainer *)prContainer
{
    NSString *addresses = [prContainer paymentAddresses];
    NSString *tgids = [prContainer receiversTgId];
    
    [GemsAnalytics track:AnalyticsSendFundsSuccess args:@{
                                                          @"chat_type": @"user",
                                                          @"recipient": addresses.length > 0? addresses: tgids,
                                                          @"origin": @"chat",
                                                          @"amount": [@(prContainer.totalOutputAmounts) stringValue],
                                                          @"currency_type": [prContainer.currency symbol],
                                                          @"asset_type": [prContainer.currency symbol],
                                                          }];
}

- (void)trackFaieldForAnalytics:(PaymentRequestsContainer *)prContainer error:(NSString*)error
{
    NSString *addresses = [prContainer paymentAddresses];
    NSString *tgids = [prContainer receiversTgId];
    
    [GemsAnalytics track:AnalyticsSendFundsError args:@{
                                                        @"chat_type": @"user",
                                                        @"recipient": addresses.length > 0? addresses: tgids,
                                                        @"origin": @"chat",
                                                        @"amount": [[NSNumber numberWithLongLong:prContainer.totalOutputAmounts] stringValue],
                                                        @"currency_type": [prContainer.currency symbol],
                                                        @"asset_type": [prContainer.currency symbol],
                                                        @"error": error
                                                        }];
}

@end
