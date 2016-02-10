//
//  TGContact.m
//  Telegraph
//
//  Created by alon muroch on 05/02/2016.
//
//

#import "TGContact.h"

@implementation TGContact

- (NSString *)firstName
{
    return _firstNameStr;
}

- (NSString *)lastName
{
    return _lastNameStr;
}

- (NSString *)displayName
{
    if(self.firstName) {
        if(self.lastName) {
            return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
        }
        else {
            return self.firstName;
        }
    }
    else {
        return @"John Doe";
    }
}

- (NSString *)subtitle
{
    return _phoneNumber;
}

- (NSString *)contactId
{
    return [NSString stringWithFormat:@"%d", self.uid];
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.uid) forKey:@"uid"];
    [aCoder encodeObject:self.firstNameStr forKey:@"firstName"];
    [aCoder encodeObject:self.lastNameStr forKey:@"lastName"];
    [aCoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [aCoder encodeObject:self.userNameStr forKey:@"userName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    TGContact *ret = [[TGContact alloc] init];
    ret.uid = [((NSNumber*)[aDecoder decodeObjectForKey:@"uid"]) intValue];
    ret.firstNameStr = [aDecoder decodeObjectForKey:@"firstName"];
    ret.lastNameStr = [aDecoder decodeObjectForKey:@"lastName"];
    ret.phoneNumber = [aDecoder decodeObjectForKey:@"phoneNumber"];
    ret.userNameStr = [aDecoder decodeObjectForKey:@"userName"];
    return ret;
}

@end
