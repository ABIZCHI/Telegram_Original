//
//  KeyboardProtocolImpl.swift
//  PayKeyboard
//
//  Created by alon muroch on 12/01/2016.
//  Copyright © 2016 Apple. All rights reserved.
//
import UIKit
import Foundation
import KeyboardFramework

public class KeyboardProtocolImp: KeyboardProtocol {
    static let instance: KeyboardProtocolImp = KeyboardProtocolImp()
    
    override init() {
        super.init()
    }
    
    override public func currency() -> PKCurrency {
        return GemsCurrency()
    }
    
    public override func setDidSwitchToPayKeyForTheFirstTime() {
        KBDefaults().didSwitchToPayKeyForTheFirstTime = true
    }
    
    override public func fetchContacts(filter filter: String?, completion: (contacts: [protocol<PKUserProtocol>]) -> Void)
    {
        completion(contacts: [])
    }
    
    // MARK: transactions
    override public func executePaymentRequest(pr: PaymentRequest, completion: (paymentRequest: PaymentRequest) -> Void) {
        completion(paymentRequest: GemsPaymentRequest.from(paymentRequests: pr))
    }
}

class GemsCurrency: PKCurrency {
    override init() {
        super.init()
        self.pretty = "Gems"
        self.symbol = "G"
    }
}

public class GemsPaymentRequest: PaymentRequest {
    class func from(paymentRequests pr: PaymentRequest) -> GemsPaymentRequest {
        let ret: GemsPaymentRequest = GemsPaymentRequest(contact: pr.contact, amount: pr.amount)
        ret.payerName = KBDefaults().stringForKey(cachedReferralLink)!
        return ret
    }
    
    
    public override func successString() -> String {
        let ud: NSUserDefaults = KBDefaults()
        if let s: String = ud.stringForKey(cachedReferralLink) {
            return s
        }
        return "http://getgems.org"
    }
    
    public override func unidentifiedUserString() -> String {
        return ""
    }
}
