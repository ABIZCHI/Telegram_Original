//
//  Analytics.swift
//  PayKeyboard
//
//  Created by alon muroch on 06/03/2016.
//  Copyright © 2016 Apple. All rights reserved.
//

import Foundation
import KeyboardFramework
import Mixpanel
import GemsNetworking

public class KBAnalytics: PKAnalytics {
    public static let instance: KBAnalytics = KBAnalytics()
    let API: GemsNetworker = GemsNetworker.sharedInstance()
    
    public override func setup(launchingOptions launchOptions: [NSObject : AnyObject]?) {
        Mixpanel.sharedInstanceWithToken("20695144b00196122fe0fe79a2f0a612")
    }
    
    public override func identify(idn: String) {
        if let idnt: String = KBDefaults().analyticsIdentity {
            Mixpanel.sharedInstance().identify(idnt)
            
            let d =  ["$first_name": KBDefaults().username,
                        "$last_name": KBDefaults().username,
                        "$phone": KBDefaults().verifiedPhoneNumber,
                        "GemUsername": KBDefaults().username,
                        "GemUserId": idnt]
            Mixpanel.sharedInstance().people.set(d)
        }
    }
    
    public override func track(event: AnalyticsEvents, params: [String: AnyObject]?) {
        if let p = params {
            Mixpanel.sharedInstance().track(event.string(), properties: p)
        }
        else {
            Mixpanel.sharedInstance().track(event.string())
        }
        
        if event == .MovedFromKeyboard {
            API.postSwitchedFromKeyboardWithRespond(nil)
        }
        if event == .MovedToKeyboard {
            API.postSwitchedToKeyboardWithRespond(nil)
        }
        
        print("Gems Analytics: tracked \(event.string()) with params \(params)")
    }
}
