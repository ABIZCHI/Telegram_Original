//
//  TGPaymentVerification.m
//  GetGems
//
//  Created by alon muroch on 9/3/15.
//
//

#import "TGPaymentVerification.h"
#import "GroupPinCodeView.h"
#import "SinglePinCodeView.h"
#import "TGUser.h"
#import "TGDatabase.h"

// GemsUI
#import <GemsUI/GemsTxConfirmationMessage.h>
#import <GemsUI/GemsAppearance.h>

// GemsCore
#import <GemsCore/GemsLocalization.h>

// Currenceis
#import <GemsCurrencyManager/GemsCurrencyManager.h>

@implementation TGPaymentVerification

- (void)verify:(PaymentRequestsContainer*)prContainer completion:(PaymentVerificationResponse)completion
{
    CDGemsUser *user = [CDGemsUser MR_findFirst];
    
    /**
     *  Group payments should always show a dialog. 
     *  If a pincode is not set for the currency, display a confirmation dialog with an 'OK' button
     */
    if(prContainer.paymentContextType == PaymentRequestGroup)
    {
        GroupPinCodeType verificationType = [prContainer groupPinCodeType];
        GroupPinCodeView *pincodeView = [GroupPinCodeView new];
        if([self pinProtected:prContainer])
        {
            [pincodeView authenticatePinhash:user.pinCodeHash
                          forPaymentRequests:prContainer
                                        type:verificationType
                                  completion:^(BOOL wasVerified, NSDictionary __unused *data, NSString __unused *errorString) {
                                      if(wasVerified) {
                                          prContainer.paymentRequests = [NSMutableArray arrayWithArray:[pincodeView selectedPaymentRequests]];
                                      }
                                      
                                      if(completion)
                                          completion(wasVerified);
                                  }];
        }
        else {
            [pincodeView confirmPaymentRequests:prContainer
                                           type:verificationType
                                     completion:^(BOOL wasVerified, NSDictionary *data, NSString *errorString) {
                                             if(wasVerified) {
                                                 prContainer.paymentRequests = [NSMutableArray arrayWithArray:[pincodeView selectedPaymentRequests]];
                                             }
                                             
                                             if(completion)
                                                 completion(wasVerified);
                                        }];
        }
    }
    
    
    /**
     *  Single and tipping should display a dialog only if a pincode is set for the currency.
     *  If the payment req has a telegram id show the SinglePinCodeView, otherwise the default pin dialog
     */
    else if(prContainer.paymentContextType == PaymentRequestSingle ||
       prContainer.paymentContextType == PaymentRequestTipping)
    {
        if([self pinProtected:prContainer])
        {
            if(((PaymentRequest*)prContainer.paymentRequests[0]).receiverTelegramID != kPaymentRequestDefaultTgId) {
                SinglePinCodeView *pincodeView = [SinglePinCodeView new];
                [pincodeView authenticatePinhash:user.pinCodeHash
                              forPaymentRequests:prContainer
                                      completion:^(BOOL wasVerified, NSDictionary __unused *data, NSString __unused *errorString) {
                                          if(completion)
                                              completion(wasVerified);
                                      }];
            }
            else {
                [self verifyUserPinCodeWithTitle:[self titleForPayment:prContainer]
                                         message:[self messageForPayment:prContainer]
                                      completion:^(bool wasVerified) {
                                          if(completion)
                                              completion(wasVerified);
                                        }];
            }
        }
        else {
            if(completion)
                completion(AUTHENTICATED);
        }

    }
    
    else if(prContainer.paymentContextType == PaymentRequestPurchase) {
        if([self pinProtected:prContainer])
        {
            [self verifyUserPinCodeWithTitle:[self titleForPayment:prContainer]
                                     message:[self messageForPayment:prContainer]
                                  completion:^(bool wasVerified) {
                                      if(completion)
                                          completion(wasVerified);
                                  }];
        }
        else {
            [self confirmActionWithTitle:[self titleForPayment:prContainer]
                                 message:[self messageForPayment:prContainer]
                              completion:^(bool wasVerified) {
                if(completion)
                    completion(wasVerified);
            }];
        }
    }
    
    else {
        if(prContainer.paymentContextType != PaymentRequestSingle) {
            [self confirmActionWithTitle:[self titleForPayment:prContainer] message:[self messageForPayment:prContainer] completion:^(bool wasVerified) {
                if(completion)
                    completion(wasVerified);
            }];
        }
        else {
            if(completion)
                completion(AUTHENTICATED);
        }
    }
}

- (NSString*)messageForPayment:(PaymentRequestsContainer*)prContainer
{
    if(prContainer.paymentContextType == PaymentRequestPurchase) {
        PaymentRequest *pr = prContainer.paymentRequests[0];
        
        return [NSString stringWithFormat:@"%@ %@ %@ %@ %@ ?",
                GemsLocalized(@"Purchase"),
                [pr Store_storeItemInfo].itemName,
                GemsLocalized(@"GemsFor"),
                formatDoubleToStringForDigitalAssetAmount([[@([pr Store_storeItemInfo].price) currency_gillosToGems] doubleValue]),
                @"Gems"];
    }
    else {
        GemsTxConfirmationMessage *confirmMsg = [prContainer confirmationMessageWithNameFetcher:^NSString *(PaymentRequest *pr) {
            TGUser *user = [TGDatabaseInstance() loadUser:pr.receiverTelegramID];
            return [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        }];
        
        return confirmMsg.completeMessage;
    }
}

@end
