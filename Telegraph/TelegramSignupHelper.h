//
//  TelegramSignupHelper.h
//  GetGems
//
//  Created by alon muroch on 6/10/15.
//
//

#import <Foundation/Foundation.h>
#import "ASWatcher.h"
#import "ASHandle.h"
#import "ActionStage.h"
#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "SGraphObjectNode.h"


@interface TelegramSignupHelper : NSObject  <ASWatcher>

@property (nonatomic, strong) ASHandle *actionHandle;

- (void)signupWithFirstName:(NSString*)firstname lastName:(NSString*)lastName phonenumber:(NSString*)phoneNumber phoneNumberHash:(NSString*)phoneNumberHash phoneCode:(NSString*)phoneCode completion:(void(^)(BOOL isSuccessfull))completion;
- (void)setUserFirstName:(NSString*)firstname completion:(void(^)(BOOL isSuccessfull))completion;

@end
