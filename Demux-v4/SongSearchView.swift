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
    
    var body: some View {
        VStack{
            var songArray = [Song]()
            Text("Search for a song...")
                .font(.system(size: 30, weight: .black, design: .default))
                .padding(10)
            SearchBar(text: $searchText)
                Spacer()
            
            Button(action: {
                let query = searchText
                let authToken = Session.globalSession.authToken
                print(query, authToken)
                var songArray = trackSearch(query: query, authToken: authToken!)
                print(songArray, "returned")
                
                
            }) {
                Text("Search")
            }
            List{
//                SongRow(song: songArray[0])
//                SongRow(song: songArray[1])
//                SongRow(song: songArray[2])
//                SongRow(song: songArray[3])
//                SongRow(song: songArray[4])
            }
            
            
        }
    }
    // Dismiss the keyboard

       
}

func trackSearch(query: String, authToken: String) -> [Song] {
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
            case .failure(let error):
                print(error)
            }
    }
    return resultsArray
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
    return resultsArray
}

struct SongSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SongSearchView(searchText: "Song...")
    }
}
