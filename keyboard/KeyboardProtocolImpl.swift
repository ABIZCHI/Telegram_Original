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
import GemsNetworking

public class KeyboardProtocolImp: KeyboardProtocol {
    static let instance: KeyboardProtocolImp = KeyboardProtocolImp()
    let API: GemsNetworker = GemsNetworker.sharedInstance()
    
    override init() {
        super.init()
    }
    
    override public func currency() -> PKCurrency {
        return GemsCurrency()
    }
    
    public override func setDidSwitchToPayKeyForTheFirstTime() {
        Defaults().didSwitchToPayKeyForTheFirstTime = true
    }
    
    override public func didSetPaymentMethod() -> Bool {
        
        // return true and not from the defaults to execute a stub payment
        return true /* Defaults().didSetPaymentMethod */
    }
    
    public func setDidSetPaymentMethod(value: Bool) {
        Defaults().didSetPaymentMethod = value
    }
    
    override public func touchIdAuthentication() -> Bool { return Defaults().touchIdAuthentication }
    
    public func setTouchIdAuthentication(value: Bool) {
        Defaults().touchIdAuthentication = value
    }
    
    override public func username() -> String { return Defaults().username }
    
    public func setUsername(username: String) {
        Defaults().username = username
    }
    
    override public func verifiedPhoneNumber() -> String? { return Defaults().verifiedPhoneNumber }
    
    func setVerifiedPhonenumber(phonenumber: String) {
        Defaults().verifiedPhoneNumber = phonenumber
    }
    
    public override func fetchContacts(filter filter: String?, completion: (contacts: [protocol<PKUserProtocol>]) -> Void)
    {
        if !ContactsWrapper.instance.finishedLoading {
            ContactsWrapper.instance
                .rac_finishedLoadingSignal()
                .deliverOnMainThread()
                .subscribeNext({ [unowned self](obj: AnyObject!) -> Void in
                    completion(contacts: self.contacts(filter))
                    })
        }
        else {
            completion(contacts: self.contacts(filter))
        }
    }
    
    // MARK: transactions
    override public func executePaymentRequest(pr: PaymentRequest, completion: (paymentRequest: PaymentRequest) -> Void) {
        if !API.authenticated {
            let error = NSError(domain: "error", code: 0, userInfo: [
                                                                    "message" : "User Not Authenticated"
                                                                        ])
            pr.error = error
            pr.successful = false
            completion(paymentRequest: pr)
            return
        }
        
        // 1
        self.userInfo(telegramId: pr.contact.contactId() /* tg id */) { (error, record: [String: AnyObject]?) -> Void in
            if let err: NSError = error {
                pr.error = err
                pr.successful = false
                pr.triedTosendToUnknown = true
                pr.executed = true
                completion(paymentRequest: GemsPaymentRequest.from(paymentRequests: pr))
            }
            else {
                // 2
                self.getLedgerIndx({ [unowned self](error, idx: Int?) -> Void in
                    if let err: NSError = error {
                        pr.error = err
                        pr.successful = false
                        completion(paymentRequest: GemsPaymentRequest.from(paymentRequests: pr))
                    }
                    else {
                        // 3
                        let gemsId = record!["userId"] as! String
                        let tgid = record!["telegramUserId"] as! String
                        
                        let dest: [[String: String]] = [
                            ["gemsId" : gemsId,
                                "destTeleUserId" : tgid,
                                "quantity" : pr.amount.stringValue]
                        ]
                        self.API.sendGems(dest, ledgerIdx: String(idx! + 1), respond: { (res: GemsNetworkRespond!) -> Void in
                            pr.executed = true
                            if let err: NSError = error {
                                pr.error = err
                                pr.successful = false
                                completion(paymentRequest: GemsPaymentRequest.from(paymentRequests: pr))
                            }
                            else {
                                let success = res.rawResponse["success"] as! Bool
                                if !success {
                                    pr.successful = false
                                    let err: NSError = NSError(domain: "", code: 0, userInfo: res.rawResponse)
                                    pr.error = err
                                    completion(paymentRequest: GemsPaymentRequest.from(paymentRequests: pr))
                                }
                                else {
                                    pr.successful = true
                                    completion(paymentRequest: GemsPaymentRequest.from(paymentRequests: pr))
                                }
                            }
                        })
                    }
                })
            }
        }
    }
    
    
    
    // MARK: helpers
    func userInfo(telegramId tgid: String, completion: (error: NSError?, record: [String: AnyObject]?) -> Void) {
        API.getGemsUserInfoByTelegramIds([["telegramUserId": tgid]]) { (res: GemsNetworkRespond!) -> Void in
            if res.hasError()
            {
                let err: NSError = res.error.NSError()!
                completion(error: err, record: nil)
            }
            else {
                let dic: NSDictionary = res.rawResponse
                if (dic["records"] as! NSArray).count > 0 {
                    let rec: [String: AnyObject] = (dic["records"] as! NSArray)[0] as! [String: AnyObject]
                    completion(error: nil, record: rec)
                }
                else {
                    let err: NSError = NSError.noUserError()
                    completion(error: err, record: nil)
                }
            }

        }
    }
    
    func getLedgerIndx(completion: (error: NSError?, idx: Int?) -> Void) {
        API.getUserLedgerIndexRequestWithRespond { (res: GemsNetworkRespond!) -> Void in
            if res.hasError()
            {
                completion(error: res.error.NSError(), idx: nil)
            }
            else {
                let dic: NSDictionary = res.rawResponse
                if let idx: Int = dic["ledgerIndex"] as? Int {
                    completion(error: nil, idx: idx)
                }
                else {
                    let err: NSError = NSError.noLedgerIdx()
                    completion(error: err, idx: nil)
                }
            }
        }
    }
    
    func contacts(filter: String?) -> [protocol<PKUserProtocol>] {
        var arr: [protocol<PKUserProtocol>] = []
        if let f = filter {
            arr = ContactsWrapper.instance.filter(byName: f)
        }
        else {
            arr = ContactsWrapper.instance.filter(byName: "")
        }
        
        return arr
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
        let ret: GemsPaymentRequest = GemsPaymentRequest(contact: pr.contact, amount: pr.amount, currencySymbol: pr.currencySymbol)
        
        ret.memo = pr.memo
        
        ret.successful = pr.successful
        ret.triedTosendToUnknown = pr.triedTosendToUnknown
        ret.executed = pr.executed
        ret.error = pr.error
        
        return ret
    }
    
    public override init(contact: protocol<PKUserProtocol>, amount: NSNumber, currencySymbol: String = "$") {
        super.init(contact: contact, amount: amount, currencySymbol: currencySymbol)
    }
    
    let SPECIAL_DIAMOND_CHAR = NSString(UTF8String: "💎")!
    let SPECIAL_MAGIC_SEPERATOR = NSString(format: "%C",0x200B)
    
    public override func successString() -> String {
        let link: String = Defaults().stringForKey(cachedReferralLink)!
        var temp: NSString = NSString(format: "%@%@%@%@%@%@%@%@%@",
            "\(SPECIAL_DIAMOND_CHAR) \(SPECIAL_MAGIC_SEPERATOR)",
            "Hey, I\'ve sent you",
            " ",
            "%3$s",
            " ",
            GemsCurrency().pretty,
            "",
            SPECIAL_MAGIC_SEPERATOR,
            "\n\nDownload Telegram with GetGems to claim your Gems and then redeem them for awesome gift cards, check out GetGems %1$s")
        temp = temp.stringByReplacingOccurrencesOfString("%3$s", withString: amount.stringValue)
        temp = temp.stringByReplacingOccurrencesOfString("%1$s", withString: link)
        
        return temp as String
    }
    
    public override func unidentifiedUserString() -> String {
        let link: String = Defaults().stringForKey(cachedReferralLink)!
        
        var temp: NSString = NSString(format:"%@%@%@%@%@%@%@",
            "\(SPECIAL_DIAMOND_CHAR) \(SPECIAL_MAGIC_SEPERATOR)",
            "Hi, I\'ve tried to send you %3$s, but you don’t have the GetGems app yet",
            " ",
            SPECIAL_MAGIC_SEPERATOR,
            "\(SPECIAL_DIAMOND_CHAR) \(SPECIAL_MAGIC_SEPERATOR)",
            SPECIAL_MAGIC_SEPERATOR,
            "\n\nDownload Telegram with GetGems to claim your Gems and then redeem them for awesome gift cards, check out GetGems %1$s")
        let amountStr = NSString(format: "%@ %@", amount.stringValue, GemsCurrency().pretty)
        temp = temp.stringByReplacingOccurrencesOfString("%3$s", withString: amountStr as String)
        temp = temp.stringByReplacingOccurrencesOfString("%1$s", withString: link)
        
        return temp as String
    }
}
