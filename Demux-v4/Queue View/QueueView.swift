//
//  QueueView.swift
//  Demux-v4
//
//  Created by Seena Shafai on 08/07/2020.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct QueueView: View {
    
    @State var searchText: String
    @State var queueArray = [Song]()
    @State var currentSong = Song()
    @State var showingAlert = false

    var body: some View {
        VStack {
            //Filtering
            Text("Search for a song...")
                .font(.system(size: 30, weight: .black, design: .default))
                .padding(-20)
            SearchBar(text: $searchText)
            
            Spacer()
            
            //Load queue (temporary)
            Button(action: {
                loadQueue() { song in
                    queueArray = song
                }
            }) {
                Text("Refresh")
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .padding(.horizontal, 15)
                    .padding(.vertical, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .padding(5)
            }
            //
            List(queueArray) { song in
                Button(action: {
                    print("alert")
                    self.showingAlert = true
                    self.currentSong = song
                }) {
                    SongRow(song: song)
                }
                //When row selected (delete function)
        }.alert(isPresented: self.$showingAlert) {
            Alert(title: Text(currentSong.name), message:Text("You are about to delete this song from the queue"), primaryButton: .destructive(Text("Delete")) {
                //Delete from queue
                removeFromQueue(song: currentSong)
                //Clear search bar
                searchText = ""
            }, secondaryButton: .cancel())
        }
        }
    }
}

func queueConfig()
{
    
}

func loadQueue(completion: @escaping ([Song]) -> Void)  {
    let endpoint = "http://localhost:9393/songs"
    var array = [Song]()
    AF.request(endpoint, method:. get, encoding: JSONEncoding.default).responseJSON { response in
        switch response.result {
            case .success(let value):
                let json = JSON(value)
                array = assignSearchResults(json: json)
                completion(array)
            case .failure(let error):
                print(error)
            }
    }
}

func assignSearchResults(json: JSON) -> [Song] {
    var song = Song()
    var resultsArray: [Song] = []
    
    for i in 0...5 {
        song.name = json[i]["name"].string!
        song.album = json[i]["album"].string!
        song.artist = json[i]["artist"].string!
        song.id = json[i]["id"].string!
        resultsArray.append(song)
    }
    print(resultsArray)
    return resultsArray
}

func removeFromQueue(song: Song) {
    let endpoint = "http://localhost:9393/songs"
//    let params = [:]
//    AF.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default).response { response in
//        print(response)
//    }
}


struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView(searchText: "")
    }
}
