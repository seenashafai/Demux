//
//  Song.swift
//  Demux-v4
//
//  Created by Seena Shafai on 02/07/2020.
//

import Foundation
import Alamofire
import SwiftyJSON

struct Song: Identifiable {
    
    //Probably the spotify URI
    var id: String = ""
    var name: String = ""
    var artist: String = ""
    var album: String = ""
    var albumImage: String = ""
    
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
    
    func parseSearchResults(json: JSON) -> [Song] {
        var song = Song()
        var resultsArray: [Song] = []
        let items = json["tracks"]["items"]
        
        for i in 0...4 {
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
    
    
    
    func addToQueue(song: Song) {
        let endpoint = "http://localhost:9393/songs"
        let params = [
            "id": song.id,
            "name": song.name,
            "artist": song.artist,
            "album": song.album,
            "image": song.albumImage
        ]
        AF.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default).response { response in
            print(response)
            print(response.request?.httpBody)
        }
    }


}
