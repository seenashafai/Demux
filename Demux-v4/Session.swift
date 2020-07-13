//
//  Session.swift
//  Demux-v4
//
//  Created by Seena Shafai on 02/07/2020.
//

import Foundation

//Class to hold session variables
class Session {
    //Init Session class for global use
    static let globalSession = Session()
    
    public var authToken: String?
    public var currentSong: Song?
    public var server = "http://824808d7c3ad.ngrok.io"
    public var joinCode: String?
    
    //Generate join code
    func randomString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let joinCode = String((0..<5).map{ _ in letters.randomElement()! })
        Session.globalSession.joinCode = joinCode

        return joinCode
    }

}


