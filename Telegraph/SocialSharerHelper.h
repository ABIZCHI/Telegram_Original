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

- (TGAttachmentSheetWindow*)inviteAttachmentSheetWindow;

- (void)copyLink;
- (void)inviteWithSms;
- (void)inviteViaFB;
- (void)inviteViaWhatsApp;
- (void)inviteViaTwitter;
-(void)inviteViaEmail;
- (void)inviteViaSms;
- (void)inviteViaTelegram;

@end
