//
//  Song.swift
//  Demux-v4
//
//  Created by Seena Shafai on 02/07/2020.
//

import Foundation
import Alamofire
import SwiftyJSON

struct Song: Identifiable, Equatable, Comparable
{
    static func < (lhs: Song, rhs: Song) -> Bool {
        return lhs.votes < rhs.votes
    }
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        return lhs.votes == rhs.votes
    }
    
    
    //Probably the spotify URI
    var id: String = ""
    var name: String = ""
    var artist: String = ""
    var album: String = ""
    var albumImage: String = ""
    var votes: Int = 0
    
    //Retreieve list of songs based on search query
    func search(query: String, authToken: String, completion: @escaping ([Song]) -> Void) {
        var urlParameters = URLComponents(string: "https://api.spotify.com/v1/search/")!
        var resultsArray = [Song]()

        urlParameters.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "track"),
            URLQueryItem(name: "market", value: "GB"),
            URLQueryItem(name: "limit", value: "5")
        ]
        AF.request(urlParameters.url!, method: .get, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer "+authToken]).responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    resultsArray = parseSearchResults(json: json)
                    print(resultsArray)
                    completion(resultsArray)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    //Parse search results into a song struct
    func parseSearchResults(json: JSON) -> [Song] {
        var song = Song()
        var resultsArray: [Song] = []
        let items = json["tracks"]["items"]
        
        for i in 0...4 {
             
            guard items[i]["uri"].string != nil else { print("json failed"); return resultsArray }
            song.name = items[i]["name"].string!
            song.album = items[i]["album"]["name"].string!
            song.artist = items[i]["album"]["artists"][0]["name"].string!
            song.id = items[i]["uri"].string!
            song.albumImage = items[i]["album"]["images"][0]["url"].string!
            resultsArray.append(song)
        
        }
        print(resultsArray)
        return resultsArray
    }
    
    
    //Add a song to the API queue
    func addToQueue(song: Song) {
        let endpoint = "\(Session.globalSession.server)/songs"
        let params = [
            "id": song.id,
            "name": song.name,
            "artist": song.artist,
            "album": song.album,
            "image": song.albumImage,
            "votes": 0
        ] as [String : Any]
        AF.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default).response { response in
            print(response)
            print(response.data)
        }
    }
    
    //Retrieve image from Spotify API using URL
    func fetchImage(imgURL: URL, completion: @escaping (UIImage) -> Void)  {
        AF.request(imgURL).responseImage { response in
            if case .success(let download) = response.result {
                print("image downloaded: \(download)")
                completion(download)
            }
        }
    }
    
    //Load queue from API, return queue array
    func loadQueue(completion: @escaping ([Song]) -> Void)  {
        let endpoint = "\(Session.globalSession.server)/songs"
        var array = [Song]()
        AF.request(endpoint, method:. get, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let count = json.count
                    print(count, "count")
                    array = assignSearchResults(json: json, count: count)
                    completion(array)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func assignSearchResults(json: JSON, count: Int) -> [Song] {
        var song = Song()
        var resultsArray: [Song] = []
        
        for i in 0...(count-1) {
            song.name = json[i]["name"].string!
            song.album = json[i]["album"].string!
            song.artist = json[i]["artist"].string!
            song.id = json[i]["id"].string!
            song.albumImage = json[i]["image"].string!
            song.votes = json[i]["votes"].int!
            resultsArray.append(song)
        }
        print(resultsArray)
        return resultsArray
    }
    
    //Remove song from queue
    func removeFromQueue(song: Song) -> [Song] {
        let id = song.id
        let array = [Song]()
        let removeURL = "\(Session.globalSession.server)/songs/\(id)"
        AF.request(removeURL, method: .delete).response { response in
            //print(response)
        }
        return array
    }
    
    func addVote(song: Song) {
        let endpoint = "\(Session.globalSession.server)/songs/\(song.id)"
        let params = ["votes": song.votes] as [String : Any]
        
        AF.request(endpoint, method: .patch, parameters: params, encoding: JSONEncoding.default).response { response in
            switch response.result {
                case .success(let value):
                    print(response.result)
                    //completion(true)
                case .failure(let error):
                    print(error)
            }
        }
    }

}
