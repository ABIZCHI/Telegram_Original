//
//  NSUserDefault+KB.swift
//  TastyImitationKeyboard
//
//  Created by alon muroch on 10/7/15.
//  Copyright (c) 2015 Apple. All rights reserved.
//

import Foundation

private let kTokenForKeyboard: String!                  = "KeyboardToken"
private let kDidSetPaymentMethod: String!               = "DidSetPaymentMethod"
private let kVerifiedPhoneNumber: String                = "VerifiedPhoneNumber"
private let kTouchIdAuthentication: String              = "TouchIdAuthentication"
private let kDidSwitchToPayKeyForTheFirstTime: String   = "DidSwitchToPayKeyForTheFirstTime"
private let kUsername: String                           = "Username"

public extension NSUserDefaults {
    
    public var didSetPaymentMethod: Bool {
        get {
            return self.boolForKey(kDidSetPaymentMethod)
        }
        set {
            self.setBool(newValue, forKey: kDidSetPaymentMethod)
        }
    }
    
    public var didSwitchToPayKeyForTheFirstTime: Bool {
        get {
            return self.boolForKey(kDidSwitchToPayKeyForTheFirstTime)
        }
        set {
            self.setBool(newValue, forKey: kDidSwitchToPayKeyForTheFirstTime)
        }
    }
    
    public var verifiedPhoneNumber: String? {
        get {
            return self.stringForKey(kVerifiedPhoneNumber)
        }
        set {
            self.setObject(newValue, forKey: kVerifiedPhoneNumber)
        }
    }
    
    public var touchIdAuthentication: Bool {
        get {
            return self.boolForKey(kTouchIdAuthentication)
        }
        set {
            self.setBool(newValue, forKey: kTouchIdAuthentication)
        }
    }
    
    public var username: String {
        get {
            if self.stringForKey(kUsername) == nil || self.stringForKey(kUsername) == "" {
                return "John Doe"
            }
            return self.stringForKey(kUsername)!
        }
        set {
            self.setObject(newValue, forKey: kUsername)
        }
    }
}

