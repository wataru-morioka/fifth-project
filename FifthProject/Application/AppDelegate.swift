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
        // Realmを利用し、ネイティブのデータを管理
        let config = Realm.Configuration(
            schemaVersion: 8,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 8) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // firebaseのgoogle認証サービスを利用
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // プッシュ通知サービスを利用
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in})
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        switch application.applicationState {
        case .inactive:
            print("バックグアウンドからプッシュ通知をタップ")
            print(userInfo)
        case .active:
            print("フォアグランドでプッシュ通知を受信")
            print(userInfo)
        case .background:
            print("バックグラウンドでプッシュ通知受信")
            print(userInfo)
        default:
            break
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // アプリがフォアグラウンドの時に通知を受け取った時に呼ばれるメソッド
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])  // 通知バナー表示、通知音の再生を指定
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("アプリバックグラウンド")
        // firebase firestoreデータベース更新監視サービス停止
        ServerMonitoringService.runningProcess.detachListener()
        // ネットワーク状態監視サービス起動
        reachability.stopNotifier()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("アプリフォアグラウンド")
        // ネットワーク状態監視サービス起動
        let _ = NetworkMonitoringService(reachability: self.reachability)
        // firebase firestoreデータベース更新監視サービス起動
        ServerMonitoringService.runningProcess.attachListener()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
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
    
    // firebase認証のユーザidトークン取得
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print(String(format: "トークン更新：%@", fcmToken))
        // 取得したトークンをブロードキャスト
        NotificationCenter.default.post(name: Notification.Name("updateToken"), object: nil, userInfo: ["token": fcmToken])
    }
    
    // firebase google認証リクエスト時
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // オフライン時、もしくはにgoogle障害時
        if let error = error {
            print(error)
            print("認証キャンセル")
            // すでに初期アカウント登録しているかチェック
            let realm = try! Realm()
            let myInfo = realm.objects(User.self)
            if myInfo.count == 0 {
                return
            }
            // アカウント登録済みだった場合、アプリ起動
            
            // ネットワーク状態監視サービス起動
            let _ = NetworkMonitoringService(reachability: self.reachability)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            // メイン画面へ遷移
            Common().moveToView(fromView: self.window, toView: "MainViewController")
            return
        }
        
        // firebaseに登録されている自身のユーザ情報取得
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // 認証確認
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                print("認証エラー")
                return
            }
            print("認証成功")
            
            // ネットワーク状態監視サービス起動
            let _ = NetworkMonitoringService(reachability: self.reachability)
            
            let realm = try! Realm()
            let results = realm.objects(User.self)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            if results.count == 0 {
                // 初期インストール時、アカウント登録画面へ遷移
                Common().moveToView(fromView: self.window, toView: "RegistrationViewController")
            }else{
                // アカウント登録済みだった場合、メイン画面へ遷移
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

