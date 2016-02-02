//
//  WalletTableHeaderSharerHelper.h
//  GetGems
//
//  Created by alon muroch on 6/8/15.
//
//

#import <Foundation/Foundation.h>
#import "TGAttachmentSheetWindow.h"

@interface SocialSharerHelper : NSObject

- (TGAttachmentSheetWindow*)inviteAttachmentSheetWindow:(UIViewController*)presentor;

- (void)copyLink;
- (void)inviteWithSms;
- (void)inviteViaFB:(UIViewController*)presentor;
- (void)inviteViaWhatsApp;
- (void)inviteViaTwitter:(UIViewController*)presentor;
- (void)inviteViaEmail:(UIViewController*)presentor;
- (void)inviteViaSms;
- (void)inviteViaTelegram;

@end
