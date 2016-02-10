//
//  TGContact.h
//  Telegraph
//
//  Created by alon muroch on 05/02/2016.
//
//

#import <Foundation/Foundation.h>
#import <KeyboardFramework/KeyboardFramework-Swift.h>
#import "ExtensionConst.h"

/**
  * A primitive class for caching telegram user info for keyboard extension
 */
@interface TGContact : NSObject <PKUserProtocol, NSCoding>

@property (nonatomic) int uid;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *firstNameStr;
@property (nonatomic, strong) NSString *lastNameStr;
@property (nonatomic, strong) NSString *userNameStr;

@end
