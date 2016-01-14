//
//  TelegramSignupHelper.m
//  GetGems
//
//  Created by alon muroch on 6/10/15.
//
//

#import "TelegramSignupHelper.h"
#import "TGSynchronizeContactsActor.h"

@interface TelegramSignupHelper()
{
    int _currentActionIndex;
     void (^_completion)(BOOL isSuccessfull);
}

@end

@implementation TelegramSignupHelper

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:NO];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)signupWithFirstName:(NSString*)firstname lastName:(NSString*)lastName phonenumber:(NSString*)phoneNumber phoneNumberHash:(NSString*)phoneNumberHash phoneCode:(NSString*)phoneCode completion:(void(^)(BOOL isSuccessfull))completion
{
    _completion = completion;
    
    static int actionIndex = 1000;
    _currentActionIndex = actionIndex++;
    
    NSLog(@"Logging user to telegram with temporary firstname %@", firstname);
    [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/service/auth/signUp/(%d)", _currentActionIndex] options:[NSDictionary dictionaryWithObjectsAndKeys:phoneNumber, @"phoneNumber", phoneCode, @"phoneCode", phoneNumberHash, @"phoneCodeHash", firstname, @"firstName", lastName, @"lastName", nil] flags:0 watcher:self];
}

- (void)setUserFirstName:(NSString*)firstname completion:(void(^)(BOOL isSuccessfull))completion
{
    _completion = completion;
    
    static int actionId = 0;
    NSString *action = [[NSString alloc] initWithFormat:@"/tg/changeUserName/(%d)", actionId++];
    NSDictionary *options = @{@"firstName" : firstname,
                               @"lastName" : @""};
    [ActionStageInstance() requestActor:action options:options flags:0 watcher:self];
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path isEqualToString:[NSString stringWithFormat:@"/tg/service/auth/signUp/(%d)", _currentActionIndex]])
    {
        if (status == ASStatusSuccess)
        {
            if ([[((SGraphObjectNode *)result).object objectForKey:@"activated"] boolValue])
            {
                NSLog(@"Logged user to telegram");
                if(_completion)
                    _completion(YES);
                
                // sync contacts
                [TGSynchronizeContactsManager instance];
            }
        }
        else
        {
            NSLog(@"Faield to log user to telegram");
            if(_completion)
                _completion(NO);
        }
    }

    if ([path hasPrefix:@"/tg/changeUserName/"])
    {
        if(_completion)
            _completion(status == ASStatusSuccess);
    }
}

@end
