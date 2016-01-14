//
//  ActionStageStub.h
//  GetGems
//
//  Created by alon muroch on 5/17/15.
//
//

#import <Foundation/Foundation.h>
#import "ASWatcher.h"

@interface ActionStageStub : NSObject

+ (BOOL)stubActionCallForPath:(NSString*)path  watcher:(id<ASWatcher>)watcher;

@end
