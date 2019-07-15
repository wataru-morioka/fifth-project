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
    init(reachability: Reachability){
        reachability.whenReachable = { reachability in
            print(String(format: "ネットワーク状態変化：オンライン"))
            Common.isOnline = true
            let _ = ServerMonitoringService.runningProcess
        }
        reachability.whenUnreachable = { _ in
            print(String(format: "ネットワーク状態変化：オフライン"))
            Common.isOnline = false
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}
