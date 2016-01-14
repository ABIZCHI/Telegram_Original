//
//  RandomGifHelper.h
//  GetGems
//
//  Created by alon muroch on 9/24/15.
//
//

#import <Foundation/Foundation.h>

static NSString * const kRandomGifSymbol = @"+gif";

@interface NSString (Conversation)

- (BOOL)Conversation_randomGifRequest;
- (NSString*)Conversation_addGifSymbol;
- (NSString*)Conversation_randomGifCategory;

@end

@interface RandomGifHelper : NSObject

+ (NSString*)wrapRandomGifMessage:(NSString*)msg referralURL:(NSString*)referralURL;

@end
