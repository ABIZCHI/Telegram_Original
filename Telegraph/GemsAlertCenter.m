//
//  GemsAlertCenter.m
//  GetGems
//
//  Created by alon muroch on 7/19/15.
//
//

#import "GemsAlertCenter.h"

#if USE_GCM == 1
#import "GCM.h"
#endif

// gemsCore
#import <GemsCore/Macros.h>

#define PENDING_ALERTS_KEY @"PENDING_ALERTS_KEY"

@implementation GemsAlertCenter

+(instancetype)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
#if USE_GCM == 1
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveGcmNotification:)
                                                     name:GcmDidReceiveNotification
                                                   object:nil];
#endif
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(applicaitonDidBecomeActive)
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    }
    return self;
}

#pragma mark - API
- (void)executeAllPendingAlerts
{
    if(_executor)
    {
        [_executor executeAlerts:[self getAllPendingAlerts]];
    }
}

#pragma mark - NSNotificationCenter
- (void)applicaitonDidBecomeActive
{
    [self executeAllPendingAlerts];
}

- (void) didReceiveGcmNotification:(NSNotification *) notification
{
#if USE_GCM == 1
    if ([[notification name] isEqualToString:GcmDidReceiveNotification])
    {
        NSDictionary *notif = notification.userInfo;
        
        NSError *jsonError;
        NSString *payload = notif[@"gpp"];
        if(!payload) return;
        NSData *objectData = [payload dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *gpp = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        NSMutableDictionary *mGpp = [NSMutableDictionary dictionaryWithDictionary:gpp];
        mGpp[@"alertId"] = notif[@"gcm.message_id"];
        
        GemsAlert *alert = [GemsAlert gemsAlertFromDictionary:mGpp];
        if(!alert) return;

        [self addAlertToDefaults:alert];
        
        if(_executor && [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        {
            [_executor executeAlerts:[self getAllPendingAlerts]];
        }
    }
#endif
}

#pragma mark - NSDefaults
- (void)addAlertToDefaults:(GemsAlert*)alert
{
    [self addAlertsToDefaults:@[alert]];
}

- (void)addAlertsToDefaults:(NSArray*)alerts
{
    NSArray *all = [self getAllAlerts];
    NSMutableArray *mAll;
    if(all)
        mAll = [NSMutableArray arrayWithArray:all];
    else
        mAll = [[NSMutableArray alloc] init];
    
    for(GemsAlert *alert in alerts) {
        NSUInteger idx = [mAll indexOfObjectPassingTest:^BOOL(GemsAlert *obj, NSUInteger idx, BOOL __unused *stop) {
            return [obj.alertId isEqualToString:alert.alertId];
        }];
        if(idx != NSNotFound) {
            [mAll replaceObjectAtIndex:idx withObject:alert];
        }
        else
            [mAll addObject:alert];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mAll];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:PENDING_ALERTS_KEY];
}

- (NSArray *)getAllAlerts
{
    return NSDefaultOrEmptyArray(PENDING_ALERTS_KEY);
}

- (NSArray *)getAllPendingAlerts
{
    NSArray *arr = [self getAllAlerts];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"wasRead == false"];
    return [arr filteredArrayUsingPredicate:pred];

    
    // For testing
//    return @[[GemsAlert gemsAlertFromDictionary:@{@"type" : @"FBLIKEBONUS",
//                                                @"wasRead" : @NO}],
//             [GemsAlert gemsAlertFromDictionary:@{@"type" : @"PASSPHRASE_REMINDER",
//                                                  @"wasRead" : @NO}],
//             [GemsAlert gemsAlertFromDictionary:@{@"type" : @"INVBONUS",
//                                                  @"wasRead" : @NO,
//                                                  @"tgid" : @"111448412",
//                                                  @"reward" : @"25000000"}]
//             ];
}

- (void)markAlertsAsRead:(NSArray*)alerts
{
    for(GemsAlert *readAlert in alerts)
    {
        readAlert.wasRead = YES;
    }
    
    [self addAlertsToDefaults:alerts];
}

@end
