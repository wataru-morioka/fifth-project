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
    fileprivate typealias OwnClass = NetworkMonitoringService
    static var isOnline = false
    
    init(reachability: Reachability){
        reachability.whenReachable = { reachability in
            print(String(format: "ネットワーク状態変化：オンライン"))
            OwnClass.isOnline = true
            ServerMonitoringService.runningProcess.attachListener()
        }
        reachability.whenUnreachable = { _ in
            print(String(format: "ネットワーク状態変化：オフライン"))
            OwnClass.isOnline = false
            ServerMonitoringService.runningProcess.detachListener()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}
