//
//  WalletTableHeaderSharerHelper.m
//  GetGems
//
//  Created by alon muroch on 6/8/15.
//
//

#import "SocialSharerHelper.h"

#import "TGAppDelegate.h"

#import "TGAttachmentSheetButtonItemView.h"
#import "NSURL+GemsReferrals.h"
#import "iToast+Gems.h"
#import "GemsAttachmentSheetHorizontalImageButtonsView.h"
#import "GemsAttachmentSheetImageItemView.h"
#import "NSURL+GemsReferrals.h"

#import "GemsContactsController.h"

#import <SHKWhatsApp.h>
#import <SHKiOSFacebook.h>
#import <SHKiOSTwitter.h>
#import <SHKMail.h>
#import <SHKItem.h>

// GemsCore
#import <GemsStringUtils.h>
#import <GemsLocalization.h>

@interface SocialSharerHelper()
{
    TGAttachmentSheetWindow *_inviteAttachmentSheetWindow;
    NSMutableArray * _inviteAttachmentViewItems;
}

@end

@implementation SocialSharerHelper

#pragma mark - invite window sheet
- (TGAttachmentSheetWindow*)inviteAttachmentSheetWindow
{
    if(!_inviteAttachmentSheetWindow) {
        _inviteAttachmentSheetWindow = [[TGAttachmentSheetWindow alloc] init];
        _inviteAttachmentSheetWindow.view.items = [self inviteAttachmentViewItems];
    }
    
    return _inviteAttachmentSheetWindow;
}

- (NSMutableArray*)inviteAttachmentViewItems
{
    if(!_inviteAttachmentViewItems) {
        _inviteAttachmentViewItems = [[NSMutableArray alloc] init];
        
        GemsAttachmentSheetHorizontalImageButtonsView *h = [[GemsAttachmentSheetHorizontalImageButtonsView alloc] init];
        
        GemsAttachmentSheetImageItemView *twitter = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"twitter_icon"] pressed:^{
            [self inviteViaTwitter];
            [[self inviteAttachmentSheetWindow] dismissAnimated:YES completion:nil];
            
        }];
        [h addItem:twitter];
        
        
        GemsAttachmentSheetImageItemView *fb = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"facebook_icon"] pressed:^{
            [self inviteViaFB];
            [[self inviteAttachmentSheetWindow] dismissAnimated:YES completion:nil];
        }];
        [h addItem:fb];
        
        GemsAttachmentSheetImageItemView *gems = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"getgems_icon"] pressed:^{
            [self inviteViaSms];
            [[self inviteAttachmentSheetWindow] dismissAnimated:YES completion:nil];
        }];
        [h addItem:gems];
        
        NSURL *whatsappURL = [NSURL URLWithString:@"whatsapp://send?text=Hello%2C%20World!"];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            GemsAttachmentSheetImageItemView *whatsapp = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"whatsapp_icon"] pressed:^{
                [self inviteViaWhatsApp];
                [[self inviteAttachmentSheetWindow] dismissAnimated:YES completion:nil];
            }];
            [h addItem:whatsapp];
        }
        
        GemsAttachmentSheetImageItemView *email = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"email_icon"] pressed:^{
            [self inviteViaEmail];
            [[self inviteAttachmentSheetWindow] dismissAnimated:YES completion:nil];
            
        }];
        [h addItem:email];
        
        GemsAttachmentSheetImageItemView *copy = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"copy_referral_link_icon"] pressed:^{
            [self copyLink];
            [[self inviteAttachmentSheetWindow] dismissAnimated:YES completion:nil];
            
        }];
        [h addItem:copy];
        
        [_inviteAttachmentViewItems addObject:h];
        
        // cancel button
        TGAttachmentSheetButtonItemView *cancelItem =[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") pressed:^
                                                      {
                                                          [[self inviteAttachmentSheetWindow] dismissAnimated:YES completion:nil];
                                                      }];
        [cancelItem setBold:true];
        [cancelItem setShowsBottomSeparator:NO];
        [cancelItem setShowsTopSeparator:NO];
        [_inviteAttachmentViewItems addObject:cancelItem];
    }
    
    return _inviteAttachmentViewItems;
}

- (void)copyLink
{
    [NSURL urlWithMyUniqueReferralLinkCompletion:^(NSURL *url, NSError *error) {
        [[UIPasteboard generalPasteboard] setString:url.absoluteString];
        NSString *toastTxt = [NSString stringWithFormat:@"%@:\n%@", GemsLocalized(@"ReferralUrlCopied"), url.absoluteString];
        [iToast showInfoToastWithText:toastTxt];
    }];
}

- (void)inviteViaSms
{
    // Move to the contacts screen and simulate pressing all the user's
    // friends for invitation
    
//    NSArray *vcs = TGAppDelegateInstance.mainNavigationController.viewControllers;
//    for(UIViewController *vc in vcs)
//    {
//        if([vc isKindOfClass:[GemsMainTabsController class]])
//        {
//            GemsMainTabsController *tc = (GemsMainTabsController*)vc;
//            tc.selectedIndex = 0; // select the contacts
//            
//            GemsContactsController *cc = (GemsContactsController*)[tc.viewControllers objectAtIndex:0]; // simulate invite friends press
//            cc.simulteInviteFriendsPressOnViewDidAppear = YES;
//        }
//    }
}

- (void)inviteViaTelegram
{
//    [NSURL urlWithMyUniqueReferralLinkCompletion:^(NSURL *url, NSError *error) {
//        NSString *msg = _R(GemsLocalized(@"InviteTextViaTelegram"), @"%1$s", url.absoluteString);
//        InviteTelegramFriendsController *v = [[InviteTelegramFriendsController alloc] initWithMessage:msg];
//        [TGAppDelegateInstance pushViewController:v animated:YES];
//    }];
}

- (void)inviteViaFB
{
    [self shareWithSharer:[SHKiOSFacebook class]];
}

- (void)inviteViaWhatsApp
{
    [self shareWithSharer:[SHKWhatsApp class]];
}

- (void)inviteViaTwitter
{
    [self shareWithSharer:[SHKiOSTwitter class]];
}

-(void)inviteViaEmail
{
    [self shareWithSharer:[SHKMail class]];
}

- (void)shareWithSharer:(Class)sharer
{
    [NSURL urlWithMyUniqueReferralLinkCompletion:^(NSURL *url, NSError __unused *error) {
        
        SHKItem *msg;

        if(sharer == [SHKiOSFacebook class])
        {
            msg = [SHKItem URL:url title:[NSString stringWithFormat:GemsLocalized(@"GemsFacebookShareText"), url.absoluteString] contentType:SHKURLContentTypeWebpage];
        }
        if(sharer == [SHKWhatsApp class])
        {
            msg = [SHKItem URL:url title:_R(GemsLocalized(@"InviteTextViaWhatsapp"), @"%1$s", @"") contentType:SHKURLContentTypeWebpage];
        }
        if(sharer == [SHKiOSTwitter class])
        {
            msg = [SHKItem URL:url title:GemsLocalized(@"InviteTextViaTwitter") contentType:SHKURLContentTypeWebpage];
        }
        if(sharer == [SHKMail class])
        {
            msg = [SHKItem URL:url title:@"GetGems" contentType:SHKURLContentTypeWebpage];
            msg.text = _R(GemsLocalized(@"InviteTextViaEMail"), @"%1$s", @"");
        }

        [sharer shareItem:msg];
    }];
}


@end
