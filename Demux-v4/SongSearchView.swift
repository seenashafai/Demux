//
//  SongSearchView.swift
//  Demux-v4
//
//  Created by Seena Shafai on 04/07/2020.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct SongSearchView: View {
    
    @State var searchText: String
    @State var songArray = [Song]()

    
    var body: some View {
        VStack{
            Text("Search for a song...")
                .font(.system(size: 30, weight: .black, design: .default))
                .padding(10)
            
            SearchBar(text: $searchText)
            Spacer()
            
            Button(action: {
                //Init query and token for track search
                let query = searchText
                let authToken = Session.globalSession.authToken
                //API request for song results
                trackSearch(query: query, authToken: authToken!) { songs in
                    songArray = songs
                }
                
                
            }) {
                Text("Search")
            }
            List(songArray) { song in
                SongRow(song: song)
            }
            
            
    }
    // Dismiss the keyboard

       
}
}

func trackSearch(query: String, authToken: String, completion: @escaping ([Song]) -> Void) {
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
                resultsArray = arrangeSearchResults(json: json)
                print(resultsArray)
                completion(resultsArray)
            case .failure(let error):
                print(error)
            }
    }
}

func arrangeSearchResults(json: JSON) -> [Song] {
    var song = Song()
    var resultsArray: [Song] = []
    let items = json["tracks"]["items"]
    
    for i in 0...4 {
        song.name = items[i]["name"].string!
        song.album = items[i]["album"]["name"].string!
        song.artist = items[i]["album"]["artists"][0]["name"].string!
        song.id = items[i]["uri"].string!
        resultsArray.append(song)
    }
    print(resultsArray)
    return resultsArray
}

struct SongSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SongSearchView(searchText: "Song...")
    }
}
