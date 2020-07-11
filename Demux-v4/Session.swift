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
    public var server = "http://893471326d2d.ngrok.io"
}


