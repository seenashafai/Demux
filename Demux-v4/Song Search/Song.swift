//
//  Song.swift
//  Demux-v4
//
//  Created by Seena Shafai on 02/07/2020.
//

import Foundation
import Alamofire
import AlamofireImage
import Firebase
import SwiftyJSON

struct Song: Identifiable, Equatable, Comparable
{
    static func < (lhs: Song, rhs: Song) -> Bool {
        return lhs.votes < rhs.votes
    }
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        return lhs.votes == rhs.votes
    }
    
    
    var id: String = ""
    var name: String = ""
    var artist: String = ""
    var album: String = ""
    var albumImage: String = ""
    var votes: Int = 0
    var played: Bool = false
    var duration: Double = 0
    
    var songDict: [String: Any] {
            return [
                "id": id,
                "name": name,
                "artist": artist,
                "album": album,
                "albumImage": albumImage,
                "votes": votes,
                "played": played,
                "duration": duration
            ]
        }
    
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
            song.duration = items[i]["duration_ms"].double!
            resultsArray.append(song)
        
        }
        print(resultsArray)
        return resultsArray
    }
    
    
    //Add a song to the API queue
    func addToQueue(song: Song) {
        
        let params = [
            "id": song.id,
            "name": song.name,
            "artist": song.artist,
            "album": song.album,
            "image": song.albumImage,
            "votes": 0,
            "played": false,
            "duration": song.duration
        ] as [String : Any]
        
        // Add a new document in collection "cities"
        Session.globalSession.db.collection("session1").document(song.id).setData(params) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                print(song.id)
            }
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
        var song = Song()
        var resultsArray: [Song] = []

        
        Session.globalSession.db.collection("session1").whereField("played", isEqualTo: false).order(by: "votes", descending: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    song = Song(id: document.data()["id"] as! String, name:  document.data()["name"] as! String, artist:  document.data()["artist"] as! String, album:  document.data()["album"] as! String, albumImage:  document.data()["image"] as! String, votes:  document.data()["votes"] as! Int, played: document.data()["played"] as! Bool, duration: document.data()["duration"] as! Double)
                    resultsArray.append(song)
                }
            }
            print(resultsArray, "rA")
            completion(resultsArray)
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
    func removeFromQueue(song: Song, completion: @escaping ([Song]) -> Void) {
        let id = song.id
        var array = [Song]()
        let removeURL = "\(Session.globalSession.server)/songs/\(id)"
        AF.request(removeURL, method: .delete).response { response in
            print(response, "deleteResponse")
            song.loadQueue() { song in
                array = song
                completion(array)
            }
        }
        
        let params = ["played": true] as [String : Any]
        
        Session.globalSession.db.collection("session1").document(song.id).setData(params, merge: true)
    }
    
    func addVote(song: Song) {
        //let endpoint = "\(Session.globalSession.server)/songs/\(song.id)"
        let params = ["votes": song.votes] as [String : Any]
        
        Session.globalSession.db.collection("session1").document(song.id).setData(params, merge: true)
    }
    
    func sortQueueByVotes(array: [Song]) -> [Song]
    {
        var sortedArray = [Song]()
        sortedArray = array.sorted(by: { $0.votes > $1.votes })
        
        return sortedArray
    }
    
    func isQueueEmpty(completion: @escaping (Bool) -> Void)
    {
        var array = [Song]()
        loadQueue() { songItem in
            array = songItem
            completion(array.isEmpty)
        }
    }

    
    func isSongPlaying(authToken: String, completion: @escaping (Bool) -> Void) {
        let playerEndpoint = "https://api.spotify.com/v1/me/player"
        var isPlaying: Bool?

        AF.request(playerEndpoint, method: .get, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer "+authToken]).responseJSON { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    isPlaying = parsePlayerResults(json: json)
                    print(isPlaying)
                    completion(isPlaying!)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    //Parse search results into a song struct
    func parsePlayerResults(json: JSON) -> Bool {
        var result: Bool?

        
        guard json[0]["is_playing"].bool != nil else { print("json failed"); return false }
        result = json[0]["is_playing"].bool
        
        return result!
    }
}

extension Song {

    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
            let name = dictionary["nameSurname"] as? String,
            let artist = dictionary["email"] as? String,
            let album = dictionary["password"] as? String,
            let albumImage = dictionary["profileImageUrl"] as? String,
            let votes = dictionary["votes"] as? Int,
            let played = dictionary["played"] as? Bool,
            let duration = dictionary["duration"] as? Double else { return nil }

        self.init(id: id, name: name, artist: artist, album: album, albumImage: albumImage, votes: votes, played: played, duration: duration)
    }
}

enum playerAction {
    case pause
    case fastforward
    case rewind
}
