//
//  RandomGifHelper.m
//  GetGems
//
//  Created by alon muroch on 9/24/15.
//
//

#import "RandomGifHelper.h"
#import "ConversationMessageHandler.h"

@implementation NSString (Conversation)

- (BOOL)Conversation_randomGifRequest
{
    NSMutableArray *components = [NSMutableArray arrayWithArray:[self componentsSeparatedByString:@" "]];
    [self clearComponents:components];
        
    if(components.count != 2 ||
       ![components[0] isEqualToString:kRandomGifSymbol] ||
       [components[1] isEqualToString:kRandomGifSymbol]) return NO;
    
    return YES;
}

- (NSString*)Conversation_randomGifCategory
{
    if(![self Conversation_randomGifRequest]) return nil;
    
    NSMutableArray *components = [NSMutableArray arrayWithArray:[self componentsSeparatedByString:@" "]];
    [self clearComponents:components];
    
    return components[1];
}

- (NSString*)Conversation_addGifSymbol
{
    return [self stringByAppendingString:kRandomGifSymbol];
}

#pragma mark - private
- (void)clearComponents:(NSMutableArray*)components {
    [components removeObjectsAtIndexes:[components indexesOfObjectsPassingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL *stop) {
        return obj == nil || [obj isEqualToString:@""] || [obj isEqualToString:@" "];
    }]];
}

@end

@implementation RandomGifHelper

+ (NSString*)wrapRandomGifMessage:(NSString*)msg referralURL:(NSString*)referralURL
{
    return [ConversationMessageHandler msgForRandomGif:msg referralURL:referralURL];
}

@end
