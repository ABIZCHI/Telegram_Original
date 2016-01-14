//
//  GetGemsCell.m
//  GetGems
//
//  Created by alon muroch on 6/22/15.
//
//

#import "GetGemsCell.h"

@implementation GetGemsCellData

+ (instancetype)dataFromDictinary:(NSDictionary*)dic
{
    GetGemsCellData *ret = [[GetGemsCellData alloc] init];
    ret.type = [GetGemsCellData challenegeType:[dic[@"type"] intValue]];
    if(ret.type == -1) return nil;
    
    if([[dic allKeys] containsObject:@"iconUrl"])
        ret.iconURL = dic[@"iconUrl"];
    if([[dic allKeys] containsObject:@"bannerUrl"])
        ret.bannerURL = dic[@"bannerUrl"];
    ret.title = dic[@"title"];
    ret.descr = dic[@"descr"];
    if(dic[@"reward"])
        ret.reward = [NSNumber numberWithLongLong:[dic[@"reward"] longLongValue]];
    if(dic[@"asset"])
        ret.currency = [dic[@"asset"] isEqualToString:@"gems"]? _G:_B;
    ret.completed = [dic[@"completed"] boolValue];
    ret.didAnimateCompletion = [dic[@"didAnimateCompletion"] boolValue];
    
    ret.dataAsDictionary = dic;
    
    return ret;
}

+ (GetGemsChallengeType)challenegeType:(int)intValue
{
    if(intValue > 12) return -1;
    return intValue;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:self.dataAsDictionary];
    [dic setObject:@(self.completed) forKey:@"completed"];
    [dic setObject:@(self.didAnimateCompletion) forKey:@"didAnimateCompletion"];
    [aCoder encodeObject:self.dataAsDictionary forKey:@"data"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSDictionary *data = [aDecoder decodeObjectForKey:@"data"];
    return [GetGemsCellData dataFromDictinary:data];
}


@end


@implementation GetGemsCell


@end
