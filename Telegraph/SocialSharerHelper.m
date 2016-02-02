//
//  WalletTableHeaderSharerHelper.m
//  GetGems
//
//  Created by alon muroch on 6/8/15.
//
//

#import "SocialSharerHelper.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "TGAppDelegate.h"
#import "TGAttachmentSheetButtonItemView.h"
#import "GemsAttachmentSheetHorizontalImageButtonsView.h"
#import "GemsAttachmentSheetImageItemView.h"
#import "GemsContactsController.h"

// GemsCore
#import <GemsCore/GemsStringUtils.h>
#import <GemsCore/GemsLocalization.h>
#import <GemsCore/NSURL+GemsReferrals.h>

// GemsUI
#import <GemsUI/iToast+Gems.h>

@interface SocialSharerHelper()
{
    TGAttachmentSheetWindow *_inviteAttachmentSheetWindow;
    NSMutableArray * _inviteAttachmentViewItems;
}

@end

@implementation SocialSharerHelper

#pragma mark - invite window sheet
- (TGAttachmentSheetWindow*)inviteAttachmentSheetWindow:(UIViewController*)presentor
{
    if(!_inviteAttachmentSheetWindow) {
        _inviteAttachmentSheetWindow = [[TGAttachmentSheetWindow alloc] init];
        _inviteAttachmentSheetWindow.view.items = [self inviteAttachmentViewItems:presentor];
    }
    
    return _inviteAttachmentSheetWindow;
}

- (NSMutableArray*)inviteAttachmentViewItems:(UIViewController*)presentor
{
    if(!_inviteAttachmentViewItems) {
        _inviteAttachmentViewItems = [[NSMutableArray alloc] init];
        
        GemsAttachmentSheetHorizontalImageButtonsView *h = [[GemsAttachmentSheetHorizontalImageButtonsView alloc] init];
        
        GemsAttachmentSheetImageItemView *twitter = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"twitter_icon"] pressed:^{
            [self inviteViaTwitter:presentor];
            [[self inviteAttachmentSheetWindow:nil] dismissAnimated:YES completion:NilCompletionBlock];
            
        }];
        [h addItem:twitter];
        
        
        GemsAttachmentSheetImageItemView *fb = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"facebook_icon"] pressed:^{
            [self inviteViaFB:presentor];
            [[self inviteAttachmentSheetWindow:nil] dismissAnimated:YES completion:NilCompletionBlock];
        }];
        [h addItem:fb];
        
        GemsAttachmentSheetImageItemView *gems = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"getgems_icon"] pressed:^{
            [self inviteViaSms];
            [[self inviteAttachmentSheetWindow:nil] dismissAnimated:YES completion:NilCompletionBlock];
        }];
        [h addItem:gems];
        
        NSURL *whatsappURL = [NSURL URLWithString:@"whatsapp://send?text=Hello%2C%20World!"];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            GemsAttachmentSheetImageItemView *whatsapp = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"whatsapp_icon"] pressed:^{
                [self inviteViaWhatsApp];
                [[self inviteAttachmentSheetWindow:nil] dismissAnimated:YES completion:NilCompletionBlock];
            }];
            [h addItem:whatsapp];
        }
        
        GemsAttachmentSheetImageItemView *email = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"email_icon"] pressed:^{
            [self inviteViaEmail:presentor];
            [[self inviteAttachmentSheetWindow:nil] dismissAnimated:YES completion:NilCompletionBlock];
            
        }];
        [h addItem:email];
        
        GemsAttachmentSheetImageItemView *copy = [[GemsAttachmentSheetImageItemView alloc] initWithImage:[UIImage imageNamed:@"copy_referral_link_icon"] pressed:^{
            [self copyLink];
            [[self inviteAttachmentSheetWindow:nil] dismissAnimated:YES completion:NilCompletionBlock];
            
        }];
        [h addItem:copy];
        
        [_inviteAttachmentViewItems addObject:h];
        
        // cancel button
        TGAttachmentSheetButtonItemView *cancelItem =[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") pressed:^
                                                      {
                                                          [[self inviteAttachmentSheetWindow:nil] dismissAnimated:YES completion:NilCompletionBlock];
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

- (void)inviteViaFB:(UIViewController*)presentor
{
    [NSURL urlWithMyUniqueReferralLinkCompletion:^(NSURL *url, NSError __unused *error) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewController *fbSheet = [SLComposeViewController
                                                composeViewControllerForServiceType:SLServiceTypeFacebook];
            [fbSheet setInitialText:[NSString stringWithFormat:GemsLocalized(@"GemsFacebookShareText"), url.absoluteString]];
            [fbSheet addURL:url];
            [presentor presentViewController:fbSheet animated:YES completion:nil];
        }
    }];
}

- (void)inviteViaWhatsApp
{
    [NSURL urlWithMyUniqueReferralLinkCompletion:^(NSURL *url, NSError __unused *error) {
        NSString * msg = _R(GemsLocalized(@"InviteTextViaWhatsapp"), @"%1$s", [url absoluteString]);
        NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
        NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
        } else {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Your device has no WhatsApp installed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)inviteViaTwitter:(UIViewController*)presentor
{
    [NSURL urlWithMyUniqueReferralLinkCompletion:^(NSURL *url, NSError __unused *error) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController
                                                   composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:GemsLocalized(@"InviteTextViaTwitter") ];
            [tweetSheet addURL:url];
            [presentor presentViewController:tweetSheet animated:YES completion:nil];
        }
    }];
}

- (void)inviteViaEmail:(UIViewController*)presentor
{
    [NSURL urlWithMyUniqueReferralLinkCompletion:^(NSURL *url, NSError __unused *error) {
        // Email Subject
        NSString *emailTitle = @"GetGems";
        // Email Content
        NSString *messageBody = _R(GemsLocalized(@"InviteTextViaEMail"), @"%1$s", [url absoluteString]);
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [presentor presentViewController:mc animated:YES completion:NilCompletionBlock];
    }];
}


@end
