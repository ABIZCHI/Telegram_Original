//
//  GemsDialogListCompanion.m
//  GetGems
//
//  Created by Onizhuk Anton on 3/14/16.
//
//

#import "GemsDialogListCompanion.h"
#import "LDAdvertisingManager.h"

@implementation GemsDialogListCompanion

- (void)actorCompleted:(int)resultCode path:(NSString *)path result:(id)result {
    if ([path hasPrefix:@"/tg/conversation/("] && [path hasSuffix:@")/delete"]) {
        NSString * braketedNumber = [[path stringByDeletingLastPathComponent] lastPathComponent];
        NSString * numberString = [braketedNumber substringWithRange:NSMakeRange(1, braketedNumber.length - 2)];
        int64_t conversationId = [numberString longLongValue];
        
        [[LDAdvertisingManager sharedManager] didLeaveChannelWithID:conversationId];
    }

    
    [super actorCompleted:resultCode path:path result:result];
    
}

@end
