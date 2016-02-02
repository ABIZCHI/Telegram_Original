//
//  BotAuthenticator.h
//  GetGems
//
//  Created by alon muroch on 8/18/15.
//
//

// GemsNetworking
#import <GemsNetworking/GemsAuthenticationService.h>

@interface BotAuthenticator : GemsAuthenticationService

- (instancetype)initWithDeviceAuth:(NSString*)deviceAuth phoneNumber:(NSString*)phoneNumber ver:(NSString*)ver;

@end
