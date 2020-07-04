//
//  SongSearchView.swift
//  Demux-v4
//
//  Created by Seena Shafai on 04/07/2020.
//

import SwiftUI
import Alamofire

struct SongSearchView: View {
    
    @State var searchText: String
    
    var body: some View {
        VStack{
            Text("Search for a song...")
                .font(.system(size: 30, weight: .black, design: .default))
                .padding(10)
            SearchBar(text: $searchText)
                Spacer()
            
            Button(action: {
                let query = searchText
                let authToken = Session.globalSession.authToken
                trackSearch(query: query, authToken: authToken!)
                
                
            }) {
                Text("Search")
            }
            
            
        }
    }
    // Dismiss the keyboard

       
}

func trackSearch(query: String, authToken: String) {
    var urlParameters = URLComponents(string: "https://api.spotify.com/v1/search/")!

    urlParameters.queryItems = [
        URLQueryItem(name: "q", value: query),
        URLQueryItem(name: "type", value: "track"),
        URLQueryItem(name: "market", value: "GB"),
        URLQueryItem(name: "limit", value: "5")
    ]

    AF.request(urlParameters.url!, method: .get, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer "+authToken]).responseJSON { response in
        print(response.debugDescription)
        //Decode response as JSON
        if let result = response.value {
            let JSON = result as! NSDictionary
            let tracks = JSON["tracks"]
        }
    }
}


struct SongSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SongSearchView(searchText: "Song...")
    }
}
