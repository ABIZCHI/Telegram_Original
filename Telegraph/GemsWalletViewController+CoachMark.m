//
//  GemsWalletViewController+CoachMark.m
//  GetGems
//
//  Created by alon muroch on 4/7/15.
//
//

#import "GemsWalletViewController+CoachMark.h"
#import "CoachMarkView.h"
#import "GemsNavigationController.h"
#import "GemsContactsController.h"

@implementation GemsWalletViewController (CoachMark)

- (NSArray*)coachMarks
{
//    CGPoint centerForCoachMark2 = CGPointMake(self.walletHeaderView.btnInviteFriends.center.x, self.walletHeaderView.frame.size.height);
//    // we can't position th coach mark under the button because its a small screen
//    if(IS_IPHONE_4) {
//        centerForCoachMark2 = CGPointMake(self.view.center.x, self.view.center.y + 50);
//    }
//    
//    return @[
//             [CoachMarkView viewWithText:TGLocalized(@"GetGems.CoachMarks.Wallet.#1") tipPoint:CGPointMake(self.walletHeaderView.center.x, self.walletHeaderView.center.y + self.walletHeaderView.frame.size.height/2 + 5) tipDirection:CMBubbleTipDirectionUp uniqueID:[GemsWalletViewControllerCoachMarksIds() objectAtIndex:1]],
//             
//             [CoachMarkView viewWithText:TGLocalized(@"GetGems.CoachMarks.Wallet.#2") tipPoint:centerForCoachMark2 tipDirection:CMBubbleTipDirectionUp uniqueID:[GemsWalletViewControllerCoachMarksIds() objectAtIndex:0] customTouchEvent:^(CoachMarkView *coachMark) {
//                 
//                 NSArray *vcs = ((GemsNavigationController*)self.navigationController).viewControllers;
//                 for(UIViewController *vc in vcs)
//                 {
//                     if([vc isKindOfClass:[GemsMainTabsController class]])
//                     {
//                         GemsMainTabsController *tc = (GemsMainTabsController*)vc;
//                         tc.selectedIndex = 0; // select the contacts
//                         
//                         GemsContactsController *cc = (GemsContactsController*)[tc.viewControllers objectAtIndex:0]; // simulate invite friends press
//                         cc.simulteInviteFriendsPressOnViewDidAppear = YES;
//                         break;
//                     }
//                 }
//                 
//                 [coachMark popOut];
//             }]
//             
//             ];
    
    
    return @[];
}

@end
