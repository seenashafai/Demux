//
//  AppDelegate.swift
//  Demux-v4
//
//  Created by Seena Shafai on 26/06/2020.
//

import UIKit

@UIApplicationMain
 
class AppDelegate: UIResponder, UIApplicationDelegate, SPTSessionManagerDelegate {
    
    
    //MARK: - SPTSessionManagerDelegate
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("success")
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("fail")
        print(error)
    }
    

    let SpotifyClientID = "f9c4ab38a6fa40a1bdfc3f5ad8156d1e"
    let SpotifyRedirectURL = URL(string: "demux://callback/")!
    

    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )

    lazy var sessionManager: SPTSessionManager = {
        //Swap tokens
      if let tokenSwapURL = URL(string: "https://tame-cottony-vegetable.glitch.me/api/token"),
         let tokenRefreshURL = URL(string: "https://tame-cottony-vegetable.glitch.me/api/refresh_token") {
        print("yes")
        //Add swap config
        self.configuration.tokenSwapURL = tokenSwapURL
        self.configuration.tokenRefreshURL = tokenRefreshURL
        self.configuration.playURI = "spotify:track:4baAwbpkroYCwSIlaqzNXy" //Shoot the Runner
        
        print(tokenSwapURL, tokenRefreshURL)
      }
      let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
      return manager
    }()
    
  
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let requestedScopes: SPTScope = [.appRemoteControl]
        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
        print("go to spotify")
        
        if (launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL) != nil {
            //Error
           }
        return true
    }



    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

