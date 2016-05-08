//
//  AppDelegate.swift
//  Automation
//
//  Created by Liu Liang on 5/1/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit
import AVFoundation
import PasscodeLock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    lazy var passcodeLockPresenter: PasscodeLockPresenter = {
        
        let configuration = PasscodeLockConfiguration()
        let presenter = PasscodeLockPresenter(mainWindow: self.window, configuration: configuration)
        
        return presenter
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        passcodeLockPresenter.presentPasscodeLock()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        passcodeLockPresenter.presentPasscodeLock()
        
        let latestCommand = CommandHelper.latestCommand
        if latestCommand != "nbt" {
            return;
        }
        
        var background_task = UIBackgroundTaskInvalid
        background_task = application.beginBackgroundTaskWithExpirationHandler({
            application.endBackgroundTask(background_task)
            background_task = UIBackgroundTaskInvalid;
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var count = 0
            while(count < 10)
            {
                let result = SshUtils.executeSshCmd(latestCommand)
                switch result {
                case .Success:
                    if result.value?.characters.count > 0 {
                        Utils.executeLocalCmd("say \(result.value!)")
                    } else {
                        print("Empty response")
                    }
                case .Failure:
                    break
                }
                
                let remainTime = UIApplication.sharedApplication().backgroundTimeRemaining
                print("Background time Remaining: \(remainTime)")
                NSThread.sleepForTimeInterval(20)
                
                if remainTime < 40 {
                    break;
                }
                
                count = count + 1
            }
            
            application.endBackgroundTask(background_task)
            background_task = UIBackgroundTaskInvalid;
        })
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("performFetchWithCompletionHandler")
        completionHandler(.NoData)
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}

