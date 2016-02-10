//
//  KeyboardViewController.swift
//  keyboard
//
//  Created by alon muroch on 03/02/2016.
//
//

import UIKit
import KeyboardFramework
import GemsNetworking

public func Defaults() -> NSUserDefaults! {
    let ret: NSUserDefaults! = NSUserDefaults(suiteName: appGroupsSuite)
    return ret
}

class KeyboardViewController: KeyboardController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version: String = "1"
        let env: ApiEnviroment = ApiEnviroment(buildNumber: version, andOS: "ios")
        let networking = GemsNetworking()
        networking.setupWithAPIEnviroment(env)
        networking.userDefaultsGroup = appGroupsSuite
        GemsNetworker.sharedInstance().networking = networking
        GemsNetworker.sharedInstance().start()
    }
    
    override func protocolImpl() -> KeyboardProtocol {
        return KeyboardProtocolImp()
    }
    
}
