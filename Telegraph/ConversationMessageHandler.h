//
//  ConversationMessageHandler.h
//  GetGems
//
//  Created by alon muroch on 4/5/15.
//
//

#import <Foundation/Foundation.h>

@interface ConversationMessageHandler : NSObject

+ (NSString*)msgForNonGemsUser:(NSString*)referralURL
    digitalCurrencyDisplayName:(NSString*)digitalCurrencyName
         digitalCurrencyAmount:(NSString*)digitalAmount
             fiatCurrencyValue:(NSString*)fiatValueStr;


+ (NSString*)msgForGemsUser:(NSString*)referralURL
 digitalCurrencyDisplayName:(NSString*)digitalCurrencyName
      digitalCurrencyAmount:(NSString*)digitalAmount
          fiatCurrencyValue:(NSString*)fiatValueStr;

+ (NSString*)msgForGroup:(NSString*)referralURL
digitalCurrencyDisplayName:(NSString*)digitalCurrencyName
   digitalCurrencyAmount:(NSString*)digitalAmount
       fiatCurrencyValue:(NSString*)fiatValueStr
               userNames:(NSArray*)names;

+ (NSString*)msgForTipping:(NSString*)referralURL
digitalCurrencyDisplayName:(NSString*)digitalCurrencyName
     digitalCurrencyAmount:(NSString*)digitalAmount
         fiatCurrencyValue:(NSString*)fiatValueStr
                 userNames:(NSArray*)names;

+ (NSString*)msgForRandomGif:(NSString*)originalMsg referralURL:(NSString*)referralURL;

+ (NSArray*)secretMsgRegexs;
+ (NSString*)getTextMsg:(NSString*)serviceMessage;
+ (BOOL)isServiceMsg:(NSString*)msg;

@end
