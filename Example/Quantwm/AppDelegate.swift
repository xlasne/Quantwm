//
//  AppDelegate.swift
//  Quantwm
//
//  Created by xlasne on 12/13/2017.
//  Copyright (c) 2017 xlasne. All rights reserved.
//

import UIKit
import Quantwm
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var disposeBag = DisposeBag()

    let qwMediator = Mediator()

    var dataModel: DataModel? = nil
    var networkMgr: NetworkMgr?  = nil
    var coordinator: Coordinator? = nil

    let themeColor = UIColor(red: 182.0/255.0, green: 182.0/255.0, blue: 182.0/255.0, alpha: 1.0)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window?.tintColor = themeColor

        let dataModel = DataModel(mediator: qwMediator)
        self.dataModel = dataModel
        qwMediator.updateActionAndRefresh(owner: "DataModel") {
            coordinator = Coordinator(mediator: qwMediator)
            networkMgr = NetworkMgr(mediator: qwMediator)
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        disposeBag = DisposeBag()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        networkMgr?.subscribeToPlaylist(disposeBag: disposeBag) {[weak self] (indexedPlaylist: PlaylistChunk) in
            print("Data Model handler Playlist index:\(indexedPlaylist.index) count:\(indexedPlaylist.playlists.count)")
            if let me = self {
                me.qwMediator.updateActionAndRefresh(owner: "DataModel") {
                    me.dataModel?.playlistsCollection.importChunck(chunk: indexedPlaylist)
                }
            }
        }

        networkMgr?.subscribeToTrack(disposeBag: disposeBag) {[weak self] (indexedTrack: TrackChunk) in
            print("Data Model handler Tracks index:\(indexedTrack.index) count:\(indexedTrack.data.count)")
            if let me = self {
                me.qwMediator.updateActionAndRefresh(owner: "DataModel") {
                    me.dataModel?.trackListCollection.importChunck(chunk: indexedTrack)
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

