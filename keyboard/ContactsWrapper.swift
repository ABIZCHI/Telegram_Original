//
//  ContactsWrapper.swift
//  PayKeyboard
//
//  Created by alon muroch on 16/11/2015.
//  Copyright © 2015 Apple. All rights reserved.
//

import Foundation
import KeyboardFramework
import ReactiveCocoa

@objc public  protocol ContactsWrapperProtocol {
    optional func finishedLoading(result: Bool)
}

public class ContactsWrapper: NSObject {
    public static let instance: ContactsWrapper = ContactsWrapper()
    
    public  var allContacts: [protocol<PKUserProtocol>] = []
    public  var finishedLoading: Bool = false
    public  var delegate: ContactsWrapperProtocol?
    
    required override public init() {
        super.init()
        self.reloadAsync()
    }
    
    public func reloadAsync() {
        async { () -> () in
            if let data: NSData = Defaults().dataForKey(cachedTGUsersKey) {
                if let uwrappedContacts = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [protocol<PKUserProtocol>] {
                    var results: [protocol<PKUserProtocol>] = []
                    var uniqueIds: [String] = []
                    for contact: protocol<PKUserProtocol> in uwrappedContacts {
                        if uniqueIds.contains(contact.contactId()) {
                            continue
                        }
                        results.append(contact)
                        uniqueIds.append(contact.contactId())
                    }
                    self.allContacts = results
                    self.finishedLoading = true
                    
                    if let d: ContactsWrapperProtocol = self.delegate {
                        d.finishedLoading!(true)
                    }
                }
            }
        }
    }
    
    public func filter(byName name: String) -> [protocol<PKUserProtocol>] {
        if name.characters.count == 0 {
            return allContacts
        }
        
        return allContacts.filter({ (element: AnyObject) -> Bool in
            let contact: protocol<PKUserProtocol> = element as! protocol<PKUserProtocol>
            
            if contact.firstName() == nil {
                return false
            }
            
            var txt: String = ""
            if let f: String = contact.firstName() {
                txt = f
            }
            if let l: String = contact.lastName() {
                txt += " \(l)"
            }
            
            if txt == "" {
                return false
            }
            
            return txt.lowercaseString.rangeOfString(name.lowercaseString) != nil
        })
    }
}

extension ContactsWrapper:  ContactsWrapperProtocol {
    public func rac_finishedLoadingSignal() -> RACSignal
    {
        self.delegate = self
        let signal = self.rac_signalForSelector(Selector("finishedLoading:"), fromProtocol: ContactsWrapperProtocol.self)
        return signal
    }
}