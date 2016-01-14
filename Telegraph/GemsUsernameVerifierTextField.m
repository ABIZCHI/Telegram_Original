//
//  GemsUserNameVerifierTextField.m
//  GetGems
//
//  Created by alon muroch on 5/25/15.
//
//

#import "GemsUsernameVerifierTextField.h"
#import "ASWatcher.h"
#import "ASHandle.h"
#import "ActionStage.h"
#import "TGDatabase.h"
#import "TGTelegraph.h"
#import "SGraphObjectNode.h"
#import "TGSignUpRequestBuilder.h"
#import "UserNotifications.h"

@interface GemsUsernameVerifierTextField () <ASWatcher, UITextFieldDelegate>
{
    NSString *_currentCheckPath;
    
    BOOL _setFirstNameToUsername;
    
    void (^_setUsenameCompletion)(BOOL isSuccessfull);
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation GemsUsernameVerifierTextField

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
    
    TGUser *user = [TGDatabaseInstance() loadUser:TGTelegraphInstance.clientUserId];
    if(user.userName && user.userName.length > 0) {
        self.text = user.userName;
        _currentUsername = user.userName;
        _usernameVerificationState = TGUsernameControllerUsernameStateValid;
    }
    
    
    self.delegate = self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)setFirstNameToUsernameBeforeCompletionWithParams:(NSDictionary*)params
{
    _setFirstNameToUsername = YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self usernameChanged:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    return YES;
}

#pragma mark - username verification
- (void)usernameChanged:(NSString *)username
{
    _currentUsername = username;
    
    if (_currentCheckPath != nil)
    {
        [ActionStageInstance() removeWatcher:self fromPath:_currentCheckPath];
        _currentCheckPath = nil;
    }
    
    if (username.length == 0)
    {
        [self setUsernameState:TGUsernameControllerUsernameStateNone username:username];
    }
    else if (![self usernameIsValid:username])
    {
        unichar c = [username characterAtIndex:0];
        TGUsernameControllerUsernameState state;
        if (c >= '0' && c <= '9')
            state = TGUsernameControllerUsernameStateStartsWithNumber;
        else
            state = TGUsernameControllerUsernameStateInvalidCharacters;
        [self setUsernameState:state username:username];
    }
    else if (username.length < 5)
    {
        [self setUsernameState:TGUsernameControllerUsernameStateTooShort username:username];
    }
    else
    {
        [self setUsernameState:TGUsernameControllerUsernameStateChecking username:username];
        
        _currentCheckPath = [[NSString alloc] initWithFormat:@"/tg/checkUsernameAvailability/(%d)", (int)[_currentUsername hash]];
        [ActionStageInstance() requestActor:_currentCheckPath options:@{@"username": _currentUsername} flags:0 watcher:self];
    }
}

- (bool)usernameIsValid:(NSString *)username
{
    for (NSUInteger i = 0; i < username.length; i++)
    {
        unichar c = [username characterAtIndex:i];
        if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (i > 0 && c >= '0' && c <= '9') || c == '_'))
            return false;
    }
    
    return true;
}

- (void)setUsernameState:(TGUsernameControllerUsernameState)state username:(NSString *)username
{
    _usernameVerificationState = state;
    if(_usernameVerificationDelegate)
        [_usernameVerificationDelegate GemsUserNameVerifierTextField:self usename:username state:state];
}

- (void)signUpWithTemporaryFirstName
{
    [self setFirstNameToUsename:@"tmpFirstName"];
}

- (void)executeWithCompletion:(void(^)(BOOL isSuccessfull))completion
{
    _setUsenameCompletion = completion;
    if(_setFirstNameToUsername)
        [self setFirstNameToUsename:_currentUsername];
    else
        [self applyUsername];
}

- (void)applyUsername
{
    NSString *path = [[NSString alloc] initWithFormat:@"/tg/applyUsername/(%lu)", (unsigned long)[_currentUsername hash]];
    [ActionStageInstance() requestActor:path options:@{@"username": _currentUsername} flags:0 watcher:self];
}

- (void)setFirstNameToUsename:(NSString*)username
{
    NSString *firstNameText = [self cleanString:_currentUsername];
    NSString *lastNameText = [self cleanString:@""];

    static int actionId = 0;
    NSString *action = [[NSString alloc] initWithFormat:@"/tg/changeUserName/(%d)", actionId++];
    NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:firstNameText, @"firstName", lastNameText, @"lastName", nil];
    [ActionStageInstance() requestActor:action options:options flags:0 watcher:self];
}

- (NSString *)cleanString:(NSString *)string
{
    if (string.length == 0)
        return @"";
    
    NSString *withoutWhitespace = [string stringByReplacingOccurrencesOfString:@" +" withString:@" "
                                                                       options:NSRegularExpressionSearch
                                                                         range:NSMakeRange(0, string.length)];
    withoutWhitespace = [withoutWhitespace stringByReplacingOccurrencesOfString:@"\n\n+" withString:@"\n\n"
                                                                        options:NSRegularExpressionSearch
                                                                          range:NSMakeRange(0, withoutWhitespace.length)];
    return [withoutWhitespace stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - ASWatcher

- (void)callCompletionWithStatus:(BOOL)status
{
    if(_setUsenameCompletion) {
         _setUsenameCompletion(status);
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path isEqualToString:_currentCheckPath])
    {
        _currentCheckPath = nil;
        
        if (status == ASStatusSuccess)
        {
            [self setUsernameState:[result[@"usernameValid"] boolValue] ? TGUsernameControllerUsernameStateValid : TGUsernameControllerUsernameStateTaken username:_currentUsername];
        }
        else
        {
            [self setUsernameState:TGUsernameControllerUsernameStateTaken username:_currentUsername];
        }
    }
    else if ([path hasPrefix:@"/tg/applyUsername/"])
    {
        NSLog(@"applied telegram username %@", _currentUsername);
        [self callCompletionWithStatus:(status == ASStatusSuccess)];
    }
    else if ([path hasPrefix:@"/tg/changeUserName/"])
    {
        if (status == ASStatusSuccess) {
            NSLog(@"changed telegram firstname to %@", _currentUsername);
            [self applyUsername];
        }
        else {
            NSLog(@"failed to change telegram firstname to %@", _currentUsername);
            [self callCompletionWithStatus:NO];
        }
    }

}



@end
