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
    
    let scenedelegate = SceneDelegate()
    let song = Song()
    @State var currentPlaying = Song()
    
    @State var searchText: String
    @State var queueArray = [Song]()
    @State var currentSong = Song()
    @State var showingAlert = false
    @State var isLoading: Bool
    @State var code: String
    @State var showingPlayer = false

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
                    queueArray = song.removeFromQueue(song: currentSong)
                    //Refresh queue
                    song.loadQueue() { song in
                        queueArray = song
                    }
                    //Clear search bar
                    searchText = ""
                }, secondaryButton: .cancel())
            }
            }.onAppear {
                isLoading = true
                song.loadQueue() { song in
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
                                scenedelegate.appRemote.authorizeAndPlayURI(queueArray[0].id)

                            }) {
                            Image(systemName: "dot.radiowaves.left.and.right")
                                .font(.largeTitle)
                                .foregroundColor(.purple)
                                .padding(.top, 10)
                            }
                            Spacer()
                            
                            //Album image
                            let url = URL(string: queueArray[0].albumImage)
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




//Generate join code
func randomString() -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let joinCode = String((0..<5).map{ _ in letters.randomElement()! })

    return joinCode
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView(searchText: "", isLoading: false, code: "")
    }
}
