//
//  LDAdvertisingChannel.h
//  GetGems
//
//  Created by Onizhuk Anton on 3/7/16.
//
//

#import <Foundation/Foundation.h>
@class TGConversation;

@interface LDAdvertisingChannel : NSObject

@property (nonatomic)           int64_t     channelId;          //channelId
@property (nonatomic, strong)   NSString *  channelName;        //channelName
@property (nonatomic, strong)   NSString *  chatId;             //chatId
@property (nonatomic)           int64_t     gemsPerAd;          //gemsPerAd
@property (nonatomic)           BOOL        status;             //status
@property (nonatomic)           int32_t     telegramChannelId;  //telegramChannelId
@property (nonatomic)           int32_t     users;              //users


@property (nonatomic, strong)   TGConversation * conversation;


- (instancetype)initWithData:(NSDictionary *)data;
+ (NSArray <LDAdvertisingChannel *> *)channelsFromArray:(NSArray *)dataArray;

- (void)updateData:(LDAdvertisingChannel *)newChannel;

- (NSDictionary *)compileDictionary;
- (NSDictionary *)compileDictionaryWithUser:(int)userId;



@end
