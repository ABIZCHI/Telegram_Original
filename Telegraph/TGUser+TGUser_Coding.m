//
//  TGUser+TGUser_Coding.m
//  Telegraph
//
//  Created by alon muroch on 04/02/2016.
//
//

#import "TGUser+TGUser_Coding.h"

@implementation TGUser (TGUser_Coding)

- (TGContact*)tgContact
{
    TGContact *ret = [TGContact new];
    ret.uid = self.uid;
    ret.firstNameStr = self.firstName;
    ret.lastNameStr = self.lastName;
    ret.phoneNumber = self.phoneNumber;
    ret.userNameStr = self.userName;
    return ret;
}

@end
