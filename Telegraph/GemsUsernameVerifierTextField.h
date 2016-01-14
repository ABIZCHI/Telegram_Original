//
//  GemsUserNameVerifierTextField.h
//  GetGems
//
//  Created by alon muroch on 5/25/15.
//
//

#import <UIKit/UIKit.h>
#import "TGUsernameController.h"

@class GemsUsernameVerifierTextField;

@protocol GemsUsernameVerifierTextFieldDelegate <NSObject>

- (void)GemsUserNameVerifierTextField:(GemsUsernameVerifierTextField*)textField usename:(NSString*)username state:(TGUsernameControllerUsernameState)state;

@end

@interface GemsUsernameVerifierTextField : UITextField

@property(nonatomic, strong) id<GemsUsernameVerifierTextFieldDelegate> usernameVerificationDelegate;
@property(nonatomic) TGUsernameControllerUsernameState usernameVerificationState;
@property(nonatomic, strong) NSString *currentUsername;


- (void)setFirstNameToUsernameBeforeCompletionWithParams:(NSDictionary*)params;
- (void)executeWithCompletion:(void(^)(BOOL isSuccessfull))completion;

@end
