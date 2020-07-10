//
//  PlayerView.swift
//  Demux-v4
//
//  Created by Seena Shafai on 08/07/2020.
//

import SwiftUI
import Alamofire
import AlamofireImage
import SwiftyJSON
import URLImage

struct PlayerView: View {
    
    let scenedelegate = SceneDelegate()
    let qV = QueueView(searchText: "", isLoading: false, code: "")
    @State var currentSong: Song?
    var currentImage: String?
    
    var body: some View {
        VStack {
            Text("Start party")
                .padding(.top, 15)
            Button(action: {
                print("Start Party")
                scenedelegate.appRemote.authorizeAndPlayURI(currentSong!.id)

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
        }.onAppear {
//            getSong() { song in
//                currentSong = song
            }
        }
    }


func fetchImage(imgURL: URL, completion: @escaping (UIImage) -> Void)  {
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

func getSong(completion: @escaping (Song) -> Void) {
    var song = Song()
    let endpoint = "http://localhost:9393/songs"
    
    AF.request(endpoint, method:. get, encoding: JSONEncoding.default).responseJSON { response in
        switch response.result {
            case .success(let value):
                let json = JSON(value)
                let count = json.count
                print(count, "count")
                song = sortResults(json: json)
                completion(song)
            case .failure(let error):
                print(error)
            }
    }
}

func sortResults(json: JSON) -> Song {
    var song = Song()
    let item = json[0]
    
        song.name = item["name"].string!
        song.album = item["album"].string!
        song.artist = item["artist"].string!
        song.id = item["id"].string!
    song.albumImage = item["image"].string!
    
    return song
}



struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
