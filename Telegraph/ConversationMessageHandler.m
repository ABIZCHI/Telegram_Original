//
//  ConversationMessageHandler.m
//  GetGems
//
//  Created by alon muroch on 4/5/15.
//
//

#import "ConversationMessageHandler.h"
#import "GemsMessageRegexHelper.h"

#define SPACE                                   @" "
#define URL_PLACEHOLDER                         @"%1$s"
#define NAMES_PLACEHOLDER                       @"%2$s"
#define AMOUNT_PLACEHOLDER                      @"%3$s"
#define ASSET_NAME_PLACEHOLDER                  @"%4$s"
#define NUMBER_REGEX                            @"(\\d+\\.?\\d*)"
#define SPECIAL_DIAMOND_CHAR                    [NSString stringWithUTF8String:"💎"]
#define SPECIAL_MAGIC_SEPERATOR                 [NSString stringWithFormat:@"%C",0x200B]
#define SPECIAL_STICKER_SEPERATOR               [NSString stringWithFormat:@"%C%C%C",0x200E,0x200E,0x200E]
#define SPECIAL_MAGIC_SERVICE_CHAR              [NSString stringWithFormat:@"%@ %@", SPECIAL_DIAMOND_CHAR, SPECIAL_MAGIC_SEPERATOR]
#define DOWNLOAD_APP_TO_RECEIVE_COINS_TXT               [NSString stringWithFormat:@"\n\n%@", GemsLocalized(@"ViralSinglePersonGemsText")]
#define DOWNLOAD_APP_TO_RECEIVE_COINS_GROUPS_TXT        [NSString stringWithFormat:@"\n\n%@", GemsLocalized(@"ViralGroupGemText")]
#define DOWNLOAD_APP_TO_RECEIVE_COINS_TIPPING_TXT       [NSString stringWithFormat:@"\n\n%@", GemsLocalized(@"ViralTipInGroupGemText")]
#define DOWNLOAD_APP_TO_RECEIVE_COINS_RANDOM_GIF_TXT    [NSString stringWithFormat:@"\n\n%@", GemsLocalized(@"ViralStickerText")]


@implementation ConversationMessageHandler

+ (NSString*)msgForNonGemsUser:(NSString*)referralURL
                                        digitalCurrencyDisplayName:(NSString*)digitalCurrencyName
                                        digitalCurrencyAmount:(NSString*)digitalAmount
                                        fiatCurrencyValue:(NSString*)fiatValueStr
{
    NSString *template = [self sendCoinsMsgTemplateForNonGemsUser];
    NSString *amount = [NSString stringWithFormat:@"%@ %@%@", digitalAmount, digitalCurrencyName, fiatValueStr];
    template = [self replaceAmountPlaceHolderWithAmount:amount original:template];
    template = [self replaceURLPlaceHolderWithURL:referralURL original:template];
    return template;
}

+ (NSString*)msgForGemsUser:(NSString*)referralURL
                                        digitalCurrencyDisplayName:(NSString*)digitalCurrencyName
                                        digitalCurrencyAmount:(NSString*)digitalAmount
                                        fiatCurrencyValue:(NSString*)fiatValueStr
{
    NSString *template = [self sendCoinsMsgTemplateForGemsUserWithDigitalCurrencyDisplayName:digitalCurrencyName fiatCurrencyValue:fiatValueStr];
    template = [self replaceAmountPlaceHolderWithAmount:digitalAmount original:template];
    template = [self replaceURLPlaceHolderWithURL:referralURL original:template];
    return template;
}

+ (NSString*)msgForGroup:(NSString*)referralURL
                                            digitalCurrencyDisplayName:(NSString*)digitalCurrencyName
                                            digitalCurrencyAmount:(NSString*)digitalAmount
                                            fiatCurrencyValue:(NSString*)fiatValueStr
                                            userNames:(NSArray*)names
{
    NSString *allNames = @"";
    for(NSString *n in names)
    {
        allNames = [NSString stringWithFormat:@"%@ %@,", allNames, n];
    }
    
    NSString *template = [self msgForParticipantInGroup];
    template = [self replaceAssetNamePlaceHolderWithAssetName:digitalCurrencyName original:template];
    template = [self replaceAmountPlaceHolderWithAmount:[NSString stringWithFormat:@"%@ %@", digitalAmount, digitalCurrencyName] original:template];
    template = [self replaceReplaceUserNames:allNames original:template];
    template = [self replaceURLPlaceHolderWithURL:referralURL original:template];
    return template;
}

+ (NSString*)msgForTipping:(NSString*)referralURL
                                            digitalCurrencyDisplayName:(NSString*)digitalCurrencyName
                                               digitalCurrencyAmount:(NSString*)digitalAmount
                                                   fiatCurrencyValue:(NSString*)fiatValueStr
                                                           userNames:(NSArray*)names
{
    NSString *allNames = @"";
    for(NSString *n in names)
    {
        allNames = [NSString stringWithFormat:@"%@ %@,", allNames, n];
    }
    
    NSString *template = [self msgForTipping];
    template = [self replaceAmountPlaceHolderWithAmount:digitalAmount original:template];
    template = [self replaceAssetNamePlaceHolderWithAssetName:digitalCurrencyName original:template];
    template = [self replaceReplaceUserNames:allNames original:template];
    template = [self replaceURLPlaceHolderWithURL:referralURL original:template];
    return template;
}

+ (NSString*)msgForRandomGif:(NSString*)originalMsg referralURL:(NSString*)referralURL
{
    NSString *template = [self msgForRandomGif:originalMsg];
    template = [self replaceURLPlaceHolderWithURL:referralURL original:template];
    return template;
}

+ (NSArray*)secretMsgRegexs
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(NSString *c in [[GemsMessageRegexHelper regexs] allKeys])
    {
        // special cases for bitcoin and its variants
        if([c isEqualToString:@"btc"]) {
            NSArray *btcVars = @[@"bitcoin", @"Bitcoin", @"BITCOIN", @"BTC", @"btc"];
            for(NSString *var in btcVars)
            {
                NSString *template = [self getTextMsg:[self sendCoinsMsgTemplateForNonGemsUser]];
                template = [self replaceAmountPlaceHolderWithAmount:[NUMBER_REGEX stringByAppendingString:@"\\"] original:template];
                
                NSString *regex = [NSString stringWithFormat:@"%@%@%@%@%@", SPECIAL_MAGIC_SERVICE_CHAR, template, @"*", SPECIAL_MAGIC_SERVICE_CHAR, @".*"];
                [arr addObject:[regex lowercaseString]];
            }
            
            continue ;
        }
        
        // special cases for gems and its variants
        if([c isEqualToString:@"gems"]) {
            NSArray *btcVars = @[@"gems", @"gemz", @"GEMS", @"GEMZ"];
            for(NSString *var in btcVars)
            {
                NSString *template = [self getTextMsg:[self sendCoinsMsgTemplateForNonGemsUser]];
                template = [self replaceAmountPlaceHolderWithAmount:[NUMBER_REGEX stringByAppendingString:@"\\"] original:template];
                
                NSString *regex = [NSString stringWithFormat:@"%@%@%@%@%@", SPECIAL_MAGIC_SERVICE_CHAR, template, @"*", SPECIAL_MAGIC_SERVICE_CHAR, @".*"];
                [arr addObject:[regex lowercaseString]];
            }
            
            continue ;
        }

        
        NSString *template = [self getTextMsg:[self sendCoinsMsgTemplateForNonGemsUser]];
        template = [self replaceAmountPlaceHolderWithAmount:[NUMBER_REGEX stringByAppendingString:@"\\"] original:template];
        
        NSString *regex = [NSString stringWithFormat:@"%@%@%@%@%@", SPECIAL_MAGIC_SERVICE_CHAR, template, @"*", SPECIAL_MAGIC_SERVICE_CHAR, @".*"];
        [arr addObject:[regex lowercaseString]];
    }
    return (NSArray*)arr;
}

+ (NSString*)serviceMsgRegex
{
    return [NSString stringWithFormat:@"^%@.*",SPECIAL_MAGIC_SERVICE_CHAR];
}

+ (NSString*)getTextMsg:(NSString*)serviceMessage
{
    if([self isStickerMsg:serviceMessage]) {
        return [serviceMessage componentsSeparatedByString:SPECIAL_STICKER_SEPERATOR][0];
    }
    else {
        if (serviceMessage == nil) return nil;
        NSArray* parts = [serviceMessage componentsSeparatedByString:SPECIAL_MAGIC_SEPERATOR];
        if (parts.count < 2) return nil;
        return [parts objectAtIndex:1];
    }
}

+ (BOOL)isServiceMsg:(NSString*)msg
{
    if ((msg == nil) || msg.length == 0) return NO;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[self serviceMsgRegex] options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:[msg lowercaseString] options:0 range:NSMakeRange(0, [[msg lowercaseString] length])];
    if(match)
    {
        return YES;
    }
    
    return [self isStickerMsg:msg];
}

+ (BOOL)isStickerMsg:(NSString*)msg
{
    return [msg rangeOfString:SPECIAL_STICKER_SEPERATOR].location != NSNotFound;
}

#pragma mark - private

+ (NSString*)sendCoinsMsgTemplateForNonGemsUser
{
    return [NSString stringWithFormat:@"%@%@%@%@%@%@%@",
            SPECIAL_MAGIC_SERVICE_CHAR,
            GemsLocalized(@"GemsNotAGemUserInviteiOS"),
            SPACE,
            SPECIAL_MAGIC_SEPERATOR,
            SPECIAL_MAGIC_SERVICE_CHAR,
            SPECIAL_MAGIC_SEPERATOR,
            DOWNLOAD_APP_TO_RECEIVE_COINS_TXT];
}

+ (NSString*)sendCoinsMsgTemplateForGemsUserWithDigitalCurrencyDisplayName:(NSString*)digitalCurrencyName fiatCurrencyValue:(NSString*)fiatValueStr
{
    return [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
            SPECIAL_MAGIC_SERVICE_CHAR,
            GemsLocalized(@"GemsTransactionMessageSingleUser"),
            SPACE,
            AMOUNT_PLACEHOLDER,
            SPACE,
            digitalCurrencyName,
            fiatValueStr,
            SPECIAL_MAGIC_SEPERATOR,
            DOWNLOAD_APP_TO_RECEIVE_COINS_TXT];
}

+ (NSString*)msgForParticipantInGroup
{
    return [NSString stringWithFormat:@"%@%@%@%@%@",
            SPECIAL_MAGIC_SERVICE_CHAR,
            GemsLocalized(@"GemsTransactionMessageGroupIndividualiOS"),
            SPACE,
            SPECIAL_MAGIC_SEPERATOR,
            DOWNLOAD_APP_TO_RECEIVE_COINS_GROUPS_TXT];
}

+ (NSString*)msgForTipping
{
    return [NSString stringWithFormat:@"%@%@%@%@%@",
            SPECIAL_MAGIC_SERVICE_CHAR,
            GemsLocalized(@"GemsTransactionMessageSingleUserTipInGroupiOS"),
            SPACE,
            SPECIAL_MAGIC_SEPERATOR,
            DOWNLOAD_APP_TO_RECEIVE_COINS_TIPPING_TXT];
}

+ (NSString*)msgForRandomGif:(NSString *)originalMsg
{
    return [NSString stringWithFormat:@"%@\n%@%@%@",
            originalMsg,
            SPECIAL_STICKER_SEPERATOR,
            DOWNLOAD_APP_TO_RECEIVE_COINS_RANDOM_GIF_TXT,
            SPECIAL_STICKER_SEPERATOR];
}

+ (NSString*)replaceURLPlaceHolderWithURL:(NSString*)url original:(NSString*)str
{
    return [str stringByReplacingOccurrencesOfString:URL_PLACEHOLDER withString:url];
}

+ (NSString*)replaceReplaceUserNames:(NSString*)names original:(NSString*)str
{
    return [str stringByReplacingOccurrencesOfString:NAMES_PLACEHOLDER withString:names];
}

+ (NSString*)replaceAmountPlaceHolderWithAmount:(NSString*)amount original:(NSString*)str
{
    return [str stringByReplacingOccurrencesOfString:AMOUNT_PLACEHOLDER withString:amount];
}

+ (NSString*)replaceAssetNamePlaceHolderWithAssetName:(NSString*)asset original:(NSString*)str
{
    return [str stringByReplacingOccurrencesOfString:ASSET_NAME_PLACEHOLDER withString:asset];
}


@end
