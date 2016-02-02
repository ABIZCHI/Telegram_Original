//
//  TGGemsWallet.m
//  GetGems
//
//  Created by alon muroch on 7/8/15.
//
//

#import "TGGemsWallet.h"
#import "TGGems.h"

#import "GemsAlert.h"
#import "GemsAlertCenter.h"
#import "TGPaymentVerification.h"

// GemsCore
#if USE_GCM == 1
#import <GCM.h>
#endif

@interface TGGemsWallet()
{
    TGPaymentVerification *_paymentVerifier;
}
@end

@implementation TGGemsWallet

- (void)load
{
    [super load];
    
    _paymentVerifier = [TGPaymentVerification new];
    self.paymentVerificationDelegate = _paymentVerifier;
    
#if USE_GCM == 1
    [self fetchPendingNotificationsWithCompletion:^(NSArray *notifications, NSString *errorString) {
        if(!errorString) {
            /**
             *  wrap the pending notification into an NSNotification
             *  and post it.
             */
            for(NSDictionary *notif in notifications) {
                NSString *gppStr;
                {
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:notif
                                                                       options:NSJSONWritingPrettyPrinted
                                                                         error:nil];
                    gppStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
                if(!gppStr) continue;
                NSDictionary *notifPayload = @{@"gpp" : gppStr, @"gcm.message_id" : notif[@"gcmid"]};
                [[NSNotificationCenter defaultCenter] postNotificationName:GcmDidReceiveNotification
                                                                    object:nil
                                                                  userInfo:notifPayload];
            }
        }
    }];
#endif
}

@end
