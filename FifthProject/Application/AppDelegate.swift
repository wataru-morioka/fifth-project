//
//  AppDelegate.swift
//  FifthProject
//
//  Created by 森岡渉 on 2019/07/04.
//  Copyright © 2019 森岡渉. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import GoogleSignIn
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    var window: UIWindow?
    let reachability = Reachability()!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let config = Realm.Configuration(
            schemaVersion: 8,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 8) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
//        application.applicationIconBadgeNumber = Common.getUnconfirmCount()
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        application.applicationIconBadgeNumber += 1
        
        switch application.applicationState {
        case .inactive:
            print("バックグアウンドからプッシュ通知をタップ")
            print(userInfo)
        case .active:
            print("フォアグランドでプッシュ通知を受信")
            print(userInfo)
        case .background:
            print(userInfo)
        default:
            break
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("アプリバックグラウンド")
        ServerMonitoringService.runningProcess.detachListener()
        reachability.stopNotifier()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("アプリフォアグラウンド")
        let _ = NetworkMonitoringService(reachability: self.reachability)
        ServerMonitoringService.runningProcess.attachListener()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("アプリ終了")
        ServerMonitoringService.runningProcess.detachListener()
        reachability.stopNotifier()
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {    return GIDSignIn.sharedInstance().handle(url,
                                                              sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                              annotation: [:])
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        print(String(format: "トークン更新：%@", fcmToken))
        NotificationCenter.default.post(name: Notification.Name("updateToken"), object: nil, userInfo: ["token": fcmToken])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print(error)
            print("認証キャンセル")
     
            let realm = try! Realm()
            let myInfo = realm.objects(User.self)
            if myInfo.count == 0 {
                return
            }
            let _ = NetworkMonitoringService(reachability: self.reachability)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            Common().moveToView(fromView: self.window, toView: "MainViewController")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                print("認証エラー")
                return
            }
            print("認証成功")
            
            let _ = NetworkMonitoringService(reachability: self.reachability)
            
            let realm = try! Realm()
            let results = realm.objects(User.self)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            if results.count == 0 {
                Common().moveToView(fromView: self.window, toView: "RegistrationViewController")
            }else{
                Common().moveToView(fromView: self.window, toView: "MainViewController")
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        print(error ?? "")
        print("エラー２")
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("エラー：dismissing Google SignIn")
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("エラー：presenting Google SignIn")
    }
}

