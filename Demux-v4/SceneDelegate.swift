//
//  SceneDelegate.swift
//  Demux-v4
//
//  Created by Seena Shafai on 26/06/2020.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    var window: UIWindow?
    let song = Song()
    var queue = [Song]()
    @State var queueIsValid = true
    //Reference app delegate for session manager
    lazy var appdelegate = AppDelegate()
    static private let kAccessTokenKey = "access-token-key"

    
    //MARK: - SPTAppRemoteDelegate
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("app remote connected")
        self.appRemote.playerAPI?.delegate = self
          self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
              debugPrint(error.localizedDescription)
            } else {
                debugPrint("subscribed to playerstate", result)
            }
          })
    }
    
    
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("error")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnected")
    }
    
    //MARK: - SPTAppRemotePlayerStateDelegate
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("player state changed")
        song.loadQueue() { songItem in
            self.queue = songItem
            guard self.queue.count > 1 else {return}
            if playerState.contextURI != URL(string: self.queue[0].id) {
                self.songDidChange()
            }
        }
        
//        let contextString = playerState.contextURI.absoluteString
//        if contextString.contains("station") {
//            print("track ended")
//            songDidChange()
//        }
        
        debugPrint(playerState.contextTitle, "contextTitle")
    }
    
    func songDidChange() {
        song.loadQueue() { songItem in
            self.queue = songItem
            self.song.removeFromQueue(song: self.queue[0]) { song in
                self.queue = song
                if self.queue.count < 2 {
                    self.queueIsValid = false
                } else {
                    remote().playerAPI?.play(self.queue[0].id, callback: defaultCallback)
                }

            }
        }
    }
    
    //Initialise app remote
    lazy var appRemote: SPTAppRemote = {
      let appRemote = SPTAppRemote(configuration: appdelegate.configuration, logLevel: .debug)
      appRemote.delegate = self
      return appRemote
    }()
    
    //Configure access token
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: SceneDelegate.kAccessTokenKey)
        }
    }
    
    
    //OpenURl to handle callback
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("callback received")
        //Check for URL
        guard let url = URLContexts.first?.url else {
            print("wtaf")
            return
        }
        
        //Doesn't run, doesn't need to- for now...
        let parameters = appRemote.authorizationParameters(from: url);
                if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
                    appRemote.connectionParameters.accessToken = access_token
                    self.accessToken = access_token
                }
        //Init ses!sion manager with callback code
        appdelegate.sessionManager.application(UIApplication.shared, open: url, options: [:])
    }
    
    
    //MARK: - UIScene Lifecycle
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(text: "", joinCode: "")

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    //App remote connect on scene activation
    func sceneDidBecomeActive(_ scene: UIScene) {
        //self.appRemote.authorizeAndPlayURI("spotify:track:4baAwbpkroYCwSIlaqzNXy" )
        self.appRemote.connect()
    }
    
    //App remote disconnect on scene deactivation
    func sceneWillResignActive(_ scene: UIScene) {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }


    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

