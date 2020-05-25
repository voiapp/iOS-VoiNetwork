//
//  ActivityIndicatorHandler.swift
//  voi-app
//
//  Created by Adam Jafer on 2018-07-03.
//  Copyright © 2018 Voi Technology. All rights reserved.
//

import Foundation
import UIKit

public final class NetworkActivity {
    private(set) static var activities: UInt = 0
    
    public static func start() {
        activities += 1
        reloadIndicatorStatus()
    }
    
    public static func stop() {
        if activities > 0 {
            activities -= 1
        }
        reloadIndicatorStatus()
    }
    
    private static func reloadIndicatorStatus() {
        if Thread.isMainThread {
            UIApplication.shared.isNetworkActivityIndicatorVisible = activities != 0
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = activities != 0
            }
        }
    }
}
