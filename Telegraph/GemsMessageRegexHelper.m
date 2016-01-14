//
//  GemsMessageRegexHelper.m
//  GetGems
//
//  Created by alon muroch on 3/18/15.
//
//

#import "GemsMessageRegexHelper.h"

@implementation GemsMessageRegexHelper

+(BOOL)isSendingValueByMsg:(NSString*)msg
{
    for(NSString *k in [[self regexs] allKeys])
    {
        NSString *regexStr = [[self regexs] objectForKey:k];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:msg options:0 range:NSMakeRange(0, [msg length])];
        if(match)
            return YES;
    }
    return false;
}

+(void)getDataFromMsg:(NSString*)msg currencyType:(NSString**)currency amount:(NSNumber**)amount toUsers:(NSMutableArray**)toUsers
{
    // check for user names starting '@'
    NSString *regexStr = @"[@]+[A-Za-z0-9-_]+";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:NULL];
    NSArray *arr = [regex matchesInString:msg options:0 range:NSMakeRange(0,  [msg length])];
    if(arr)
    {
        for(NSTextCheckingResult *match in arr)
        {
            NSRange r = [match rangeAtIndex:0];
            NSString *s = [msg substringWithRange:r];
            s = [s substringFromIndex:1]; // remove '@'
            [*toUsers addObject:s];
        }
    }
    
    msg = [regex stringByReplacingMatchesInString:msg options:0 range:NSMakeRange(0, msg.length) withTemplate:@""];
    
    for(NSString *k in [[self regexs] allKeys])
    {
        NSString *regexStr = [[self regexs] objectForKey:k];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:msg options:0 range:NSMakeRange(0, [msg length])];
        if(match)
        {
            NSRange r;
            *currency = [k uppercaseString];
            NSRange twoRange = [(*currency) rangeOfString:@"2"];
            if(twoRange.location != NSNotFound) {
                *currency = [(*currency) stringByReplacingOccurrencesOfString:@"2" withString:@""];
                
                r = [match rangeAtIndex:2];
                NSString *d = [msg substringWithRange:r];
                *amount = [NSNumber numberWithDouble:[d doubleValue]];
            }
            else {
                r = [match rangeAtIndex:1];
                NSString *d = [msg substringWithRange:r];
                *amount = [NSNumber numberWithDouble:[d doubleValue]];
            }
            
            break;
        }
    }
}

+(NSDictionary*)regexs
{
    return @{@"gems":@"(\\d+\\.?\\d*) *(gem|gems)\\s*$",
             @"gems2": @"(gem|gems) *(\\d+\\.?\\d*)\\s*$",
             
             @"btc":@"(\\d+\\.?\\d*) *(btc|bitcoin|bitcoins)\\s*$",
             @"btc2": @"(btc|bitcoin|bitcoins) *(\\d+\\.?\\d*)\\s*$",
             
             @"bits":@"(\\d+\\.?\\d*) *(bit|bits)\\s*$",
             @"bits2": @"(bit|bits) *(\\d+\\.?\\d*)\\s*$",
             
             @"usd":@"(\\d+\\.?\\d*) *(\\$|usd|dollar|dollars)\\s*$",
             @"usd2": @"(\\$|usd|dollar|dollars) *(\\d+\\.?\\d*)\\s*$",
            
             @"eur":@"(\\d+\\.?\\d*) *(€|eur)\\s*$",
             @"eur2": @"(€|eur|euro) *(\\d+\\.?\\d*)\\s*$",
             
             @"gbp":@"(\\d+\\.?\\d*) *(£|gbp)\\s*$",
             @"gbp2": @"(£|gbp) *(\\d+\\.?\\d*)\\s*$",
             
             @"cad":@"(\\d+\\.?\\d*) *(cad)\\s*$",
             @"cad2": @"(cad) *(\\d+\\.?\\d*)\\s*$",
             
             @"rub":@"(\\d+\\.?\\d*) *(₽|rub)\\s*$",
             @"rub2": @"(₽|rub) *(\\d+\\.?\\d*)\\s*$",
             
             @"cny":@"(\\d+\\.?\\d*) *(¥|cny|yuan)\\s*$",
             @"cny2": @"(¥|cny|yuan) *(\\d+\\.?\\d*)\\s*$",
             
             @"jpy":@"(\\d+\\.?\\d*) *(¥|jpy)\\s*$",
             @"jpy2": @"(¥|jpy) *(\\d+\\.?\\d*)\\s*$",
             
             @"ils":@"(\\d+\\.?\\d*) *(₪|ils|nis)\\s*$",
             @"ils2": @"(₪|ils|nis) *(\\d+\\.?\\d*)\\s*$",
             };
}

#pragma mark - locate user references

- (void)locateUserNames:(NSString*)s
{
    NSString *regexStr = @"/[#]+[A-Za-z0-9-_]+/g";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:s options:0 range:NSMakeRange(0, [s length])];
    if(match)
    {
        
    }
}


@end
