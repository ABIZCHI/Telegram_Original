//
//  GemsContactsController.h
//  GetGems
//
//  Created by alon muroch on 3/17/15.
//
//

#import "TGContactsController.h"
#import "TGAttachmentSheetWindow.h"
#import "TGAttachmentSheetItemView.h"

@interface GemsContactsController : TGContactsController <UITableViewDelegate, UITableViewDataSource>
{
    
}

@property(nonatomic) BOOL simulteInviteFriendsPressOnViewDidAppear;

@end
