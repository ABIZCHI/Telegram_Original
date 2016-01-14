//
//  GemsBotAuthenticationMsg.h
//  GetGems
//
//  Created by alon muroch on 8/18/15.
//
//

#import "GemsBotMessageBase.h"

@interface GemsBotAuthenticationMsg : GemsBotMessageBase

@property (nonatomic, strong) NSString *jwtToken;
@property (nonatomic, assign) BOOL wasRegistering;
@property (nonatomic, strong) NSString *gemsId;

- (instancetype)initWithDeviceAuth:(NSString*)deviceAuth phoneNumber:(NSString*)phoneNumber ver:(NSString*)ver;

@end
