//
//  AppDelegate.swift
//  ResumeData
//
//  Created by wenjing on 2019/11/1.
//  Copyright © 2019 wenjing. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundCompletionHandler:(()->())?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
         self.window?.makeKeyAndVisible()
        let nav = creatOneViewController(title: "下载中", rootVC: DownloadViewController())
        let nav1 = creatOneViewController(title: "完成", rootVC: FinshViewController())
        let tabbar = UITabBarController()
        tabbar.viewControllers = [nav,nav1]
        self.window?.rootViewController = tabbar
        DownloadTool.shareInstance
        return true
    }

        private func creatOneViewController(title: String, rootVC: UIViewController) -> UINavigationController {
            let nav = UINavigationController(rootViewController: rootVC)
            let item = UITabBarItem()
            item.title = title
            nav.tabBarItem = item
            rootVC.title = title
            return nav
        }
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        self.backgroundCompletionHandler = completionHandler
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
//            self.endBackgroundTask()
        })
    }
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}


