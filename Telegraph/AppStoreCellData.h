//
//  AppStoreCellData.h
//  GetGems
//
//  Created by alon muroch on 6/21/15.
//
//

#import <Foundation/Foundation.h>

@interface AppStoreCellData : NSObject

@property (nonatomic, strong) NSDictionary *dataAsDictionary;

+ (instancetype)dataFromDictinary:(NSDictionary*)dic;

@end
