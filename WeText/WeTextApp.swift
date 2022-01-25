//
//  WeTextApp.swift
//  WeText
//
//  Created by Santhosh Srinivas on 14/12/21.
//

import SwiftUI
import Firebase

@main
struct WeTextApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            MainMsgView()
//            SwiftUIView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
        return true
    }
    
//    func application(_ application: UIApplication, open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey: Any])
//      -> Bool {
//      return GIDSignIn.sharedInstance.handle(url)
//    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        return
    }
}

