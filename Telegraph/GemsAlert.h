//
//  GemsAlert.h
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import <Foundation/Foundation.h>
#import "GemsAlertCommons.h"
#import "GemsAlertViewBase.h"

@interface GemsAlert : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) GemsAlertType type;
@property (nonatomic, strong) NSDictionary *rawData;
@property (nonatomic, assign) BOOL wasRead;
@property (nonatomic, strong) NSString *alertId;

- (instancetype)initWithDic:(NSDictionary*)dic;
- (GemsAlertViewBase *)alertView;

+ (instancetype)gemsAlertFromDictionary:(NSDictionary *)dic;

@end

