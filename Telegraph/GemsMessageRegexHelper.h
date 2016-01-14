//
//  GemsMessageRegexHelper.h
//  GetGems
//
//  Created by alon muroch on 3/18/15.
//
//

#import <Foundation/Foundation.h>

@interface GemsMessageRegexHelper : NSObject

+(BOOL)isSendingValueByMsg:(NSString*)msg;
+(void)getDataFromMsg:(NSString*)msg currencyType:(NSString**)currency amount:(NSNumber**)amount toUsers:(NSMutableArray**)toUsers;
+(NSDictionary*)regexs;

@end
