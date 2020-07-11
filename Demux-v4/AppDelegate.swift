//
//  AppDelegate.swift
//  Demux-v4
//
//  Created by Seena Shafai on 26/06/2020.
//

import UIKit

@UIApplicationMain
 
class AppDelegate: UIResponder, UIApplicationDelegate, SPTSessionManagerDelegate {
    
    let scenedelegate = SceneDelegate()
    
    //MARK: - SPTSessionManagerDelegate
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("success")
        Session.globalSession.authToken = session.accessToken
        //scenedelegate.appRemote.connectionParameters.accessToken = session.accessToken
        
        //scenedelegate.appRemote.connect()
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("fail")
        print(error)
    }
    
    //MARK: - SPTConfiguration
    let SpotifyClientID = "f9c4ab38a6fa40a1bdfc3f5ad8156d1e"
    let SpotifyRedirectURL = URL(string: "demux://callback/")!
    
    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )

    //MARK: - SPTSessionManager
    lazy var sessionManager: SPTSessionManager = {
        //Swap tokens
        if let tokenSwapURL = URL(string: "https://tame-cottony-vegetable.glitch.me/api/token"),
        let tokenRefreshURL = URL(string: "https://tame-cottony-vegetable.glitch.me/api/refresh_token") {
        //Add swap config
        self.configuration.tokenSwapURL = tokenSwapURL
        self.configuration.tokenRefreshURL = tokenRefreshURL
        //self.configuration.playURI = ""
        print("config complete")
    }
        //Initialize session manager
        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
        return manager
    }()
    
    
    //MARK: - AppDelegate Lifecycle
    
    //Automatically runs once app has finished launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Define scopes
        let requestedScopes: SPTScope = [.appRemoteControl]
        //Initialize Auth modal
        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
        print("auth modal presented")
        
        if (launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL) != nil {
            //Error
        }
        return true
    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


}

