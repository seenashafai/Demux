//
//  QueueView.swift
//  Demux-v4
//
//  Created by Seena Shafai on 08/07/2020.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import URLImage

struct QueueView: View {
    
    @State var searchText: String
    @State var queueArray = [Song]()
    @State var currentSong = Song()
    @State var currentPlaying = Song()
    @State var showingAlert = false
    @State var isLoading: Bool
    @State var code: String
    @State private var transition = false
    @State var currentImage: String?
    @State var showingPlayer = false
    let scenedelegate = SceneDelegate()

    var body: some View {
        ZStack {
            VStack {
                Text("Join code: \(code)")
                HStack {
                //Filtering
               
                Text("Search for a song")
                    .font(.system(size: 30, weight: .black, design: .default))
                    .padding(.top, -20)
                    .padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                
                
                Spacer()
                Button(action: {
                    self.showingPlayer = true
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.purple)
                        .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .padding(.top, -15)
                    }
                }
                SearchBar(text: $searchText)
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
                    Session.globalSession.currentSong = queueArray[0]
                    isLoading = false
                    code = randomString()
                }
            }
        // The Custom Popup is on top of the screen
                    if $showingPlayer.wrappedValue {
                        // But it will not show unless this variable is true
                        ZStack {
                            Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.vertical)
                            // This VStack is the popup
                            VStack(spacing: 20) {
                                Text("Spotify Player")
                                    .bold().padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange)
                                    .foregroundColor(Color.white)
                                Spacer()
                                VStack {
                                    Text("Start party")
                                        .padding(.top, 15)
                                    Button(action: {
                                        print("Start Party")
                                        scenedelegate.appRemote.authorizeAndPlayURI(currentSong.id)

                                    }) {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .font(.largeTitle)
                                        .foregroundColor(.purple)
                                        .padding(.top, 10)
                                    }
                                    Spacer()
                                    let url = URL(string: Session.globalSession.currentSong!.albumImage)
                                    URLImage(url!,
                                        processors: [ Resize(size: CGSize(width: 100.0, height: 100.0), scale: UIScreen.main.scale) ],
                                        content:  {
                                            $0.image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .clipped()
                                        })
                                            .frame(width: 130.0, height: 130.0)
                                    Text("Now playing...")
                                    
                                    
                                    

                                    
                                    
                                    Spacer()
                                    HStack {
                                        Button(action: {
                                            print("fast forward button pressed")

                                        }) {
                                        Image(systemName: "forward.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.purple)
                                            .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                            .padding(.top, -15)
                                        }
                                        Button(action: {
                                            print("play button pressed")
                                            
                                            
                                            
                                        }) {
                                            Image(systemName: "playpause.fill")
                                                .font(.largeTitle)
                                                .foregroundColor(.purple)
                                                .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                                .padding(.top, -15)
                                        }
                                        Button(action: {
                                            print("rewind button pressed")

                                                }) {
                                                Image(systemName: "backward.fill")
                                                    .font(.largeTitle)
                                                    .foregroundColor(.purple)
                                                    .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                                    .padding(.top, -15)
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    self.showingPlayer = false
                                }) {
                                    Text("Close")
                                }.padding()
                            }
                            .frame(width: 400, height: 500)
                            .background(Color.white)
                            .cornerRadius(20).shadow(radius: 20)
                        }
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

func fetchImage2(imgURL: URL, completion: @escaping (UIImage) -> Void)  {
    var image: UIImage?
    AF.request(imgURL).responseImage { response in

        print(response.request)
        print(response.response)
        debugPrint(response.result)

        if case .success(let download) = response.result {
            print("image downloaded: \(download)")
            completion(download)
        }
    }
    
}

//Generate join code
func randomString() -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let joinCode = String((0..<5).map{ _ in letters.randomElement()! })

    return joinCode
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
        resultsArray.append(song)
    }
    print(resultsArray)
    return resultsArray
}

func removeFromQueue(song: Song) -> [Song] {
    let id = song.id
    let array = [Song]()
    let removeURL = "http://localhost:9393/songs/\(id)"
    AF.request(removeURL, method: .delete).response { response in
        print(response)
    }
    return array
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView(searchText: "", isLoading: false, code: "")
    }
}
