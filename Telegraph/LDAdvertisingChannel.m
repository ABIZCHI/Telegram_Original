//
//  LDAdvertisingChannel.m
//  GetGems
//
//  Created by Onizhuk Anton on 3/7/16.
//
//

#import "LDAdvertisingChannel.h"

#define extract(dict, key) ([[NSNull null] isEqual:dict[key]] ? nil : dict[key])

@implementation LDAdvertisingChannel

/*
 @property (nonatomic, assign)   int64_t     channelId;          //channelId
 @property (nonatomic, copy)     NSString *  channelName;        //channelName
 @property (nonatomic, copy)     NSString *  chatId;             //chatId
 @property (nonatomic, assign)   int64_t     gemsPerAd;          //gemsPerAd
 @property (nonatomic, assign)   BOOL        status;             //status
 @property (nonatomic, assign)   int32_t     telegramChannelId;  //telegramChannelId
 @property (nonatomic, assign)   int32_t     users;              //users

 */

#pragma mark - Initialization

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        
        self.channelId =            (int64_t)[extract(data, @"channelId") integerValue];
        self.channelName =          extract(data, @"channelName");
        self.chatId =               extract(data, @"chatId");
        self.gemsPerAd =            (int64_t)[extract(data, @"gemsPerAd") integerValue];
        self.status =               [extract(data, @"status") boolValue];
        self.telegramChannelId =    ABS((int32_t)[extract(data, @"telegramChannelId") integerValue]);
        self.users =            (int32_t)[extract(data, @"users") integerValue];
        
        if (self.channelId == 0 || [self.chatId isEqualToString:@""] || self.telegramChannelId == 0) {
            return nil;
        }
        
    } return self;
}

+ (NSArray <LDAdvertisingChannel *> *)channelsFromArray:(NSArray *)dataArray {
    NSMutableArray * retArr = [[NSMutableArray alloc] initWithCapacity:dataArray.count];
    
    for (NSDictionary * data in dataArray) {
        LDAdvertisingChannel * channel = [[LDAdvertisingChannel alloc] initWithData:data];
        
        if (channel) {
            [retArr addObject:channel];
        }
        
    }
    
    if (retArr.count == 0) {
        return nil;
    } else {
        return retArr;
    }
    
}

#pragma mark - Publick Methods

- (NSDictionary *)compileDictionary {
    return [self compileDictionaryWithUser:self.users];
}

- (NSDictionary *)compileDictionaryWithUser:(int)userId {
    return @{
             @"channelId" :         [NSNumber numberWithLongLong:self.channelId],
             @"channelName" :       [NSString stringWithString:self.channelName],
             @"chatId" :            [NSString stringWithString:self.chatId],
             @"gemsPerAd" :         [NSNumber numberWithLongLong:self.gemsPerAd],
             @"status" :            [NSNumber numberWithInt:self.status],
             @"telegramChannelId" : [NSNumber numberWithLong:(-self.telegramChannelId)],
             @"users" :             [NSNumber numberWithLong:self.users],
             @"user" :              [NSNumber numberWithInt:userId]
             };
}

- (void)updateData:(LDAdvertisingChannel *)newChannel {
//    self.channelId =            newChannel.channelId;
//    self.channelName =          extract(data, @"channelName");
//    self.chatId =               extract(data, @"chatId");
    self.gemsPerAd =            newChannel.gemsPerAd;
    self.status =               newChannel.status;
//    self.telegramChannelId =    ABS((int32_t)[extract(data, @"telegramChannelId") integerValue]);
    self.users =                newChannel.users;
    
    
    self.conversation =         newChannel.conversation;

}


@end
