//
//  Queue.swift
//  Demux-v4
//
//  Created by Seena Shafai on 07/07/2020.
//

import Foundation

//Class to hold the main queue
class Queue {
    //Init Session class for global use
    static let mainQueue = Queue()
    
    public var queueArray = [Song]()
}
