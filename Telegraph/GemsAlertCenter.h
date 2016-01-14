//
//  GemsAlertCenter.h
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import <Foundation/Foundation.h>
#import "GemsAlertCommons.h"
#import "GemsAlertExecutor.h"

@interface GemsAlertCenter : NSObject

+ (instancetype)sharedInstance;

- (void)executeAllPendingAlerts;
- (void)addAlertsToDefaults:(NSArray*)alerts;
- (NSArray *)getAllAlerts;
- (NSArray *)getAllPendingAlerts;
- (void)markAlertsAsRead:(NSArray*)alerts;

@property (nonatomic, strong) GemsAlertExecutor *executor;

@end
