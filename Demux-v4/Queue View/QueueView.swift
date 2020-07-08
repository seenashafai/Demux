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
    @State var isLoading: Bool

    var body: some View {
        VStack {
            //Filtering
            Text("Search for a song...")
                .font(.system(size: 30, weight: .black, design: .default))
                .padding(-20)
            SearchBar(text: $searchText)
            
            Spacer()
            
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
                queueArray = removeFromQueue(song: currentSong)
                //Refresh queue
                loadQueue() { song in
                    queueArray = song
                }
                //Clear search bar
                searchText = ""
            }, secondaryButton: .cancel())
        }
        }.onAppear {
            isLoading = true
            loadQueue() { song in
                queueArray = song
                isLoading = false
            }
        }
    }
}

func loadQueue(completion: @escaping ([Song]) -> Void)  {
    let endpoint = "http://localhost:9393/songs"
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
        resultsArray.append(song)
    }
    print(resultsArray)
    return resultsArray
}

func removeFromQueue(song: Song) -> [Song] {
    let id = song.id
    var array = [Song]()
    let removeURL = "http://localhost:9393/songs/\(id)"
    AF.request(removeURL, method: .delete).response { response in
        print(response)
    }
    return array
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView(searchText: "", isLoading: false)
    }
}
