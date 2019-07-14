//
//  NetworkMonitoringService.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/14.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import Foundation
import Reachability

class NetworkMonitoringService {
    let reachability = Reachability()!
    init(){
        if let reachability = Reachability() {
            print("ネットワーク状況取得")
            print(!(reachability.connection == .none))
            Singleton.isOnline = !(reachability.connection == .none)
        }
        
        reachability.whenReachable = { reachability in
            print(String(format: "ネットワーク状態変化：オンライン"))
            Singleton.isOnline = true
        }
        reachability.whenUnreachable = { _ in
            print(String(format: "ネットワーク状態変化：オフライン"))
            Singleton.isOnline = false
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}
