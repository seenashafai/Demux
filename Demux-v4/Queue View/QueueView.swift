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
    var playerState: SPTAppRemotePlayerState?

    @State var currentPlaying = Song()
    @State var currentPlayingIndex: Int
    @State var isPlaying = Bool()
    @State var isPartyActive = Bool()
    
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
                    Session.globalSession.currentSong = queueArray[currentPlayingIndex]
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
                    // Begin popup
                    VStack {
                        Text("Spotify Player")
                            .bold().padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(Color.white)
                        Spacer()
                        VStack {
                            if !self.isPartyActive {
                                Text("Start party")
                                    .padding(.top, 15)
                                Button(action: {
                                    print("Start Party")
                                    currentPlayingIndex = 0
                                    remote().authorizeAndPlayURI(queueArray[currentPlayingIndex].id)
                                    isPlaying = true
                                    isPartyActive = true
                                    
                                }) {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .font(.largeTitle)
                                        .foregroundColor(.green)
                                        .padding(.top, 10)
                                }
                            } else {
                                Text("Stop party")
                                    .padding(.top, 15)
                                Button(action: {
                                    print("stop party ")
                                    remote().disconnect()
                                    isPlaying = false
                                    isPartyActive = false
                                }) {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .font(.largeTitle)
                                        .foregroundColor(.red)
                                        .padding(.top, 10)
                                        .opacity(0.4)
                                }
                            }
                            Spacer()
                            if self.isPlaying {
                                Text("Now playing...")
                                //Album image
                                let url = URL(string: queueArray[currentPlayingIndex].albumImage)
                                URLImage(url!,
                                         processors: [ Resize(size: CGSize(width: 100.0, height: 100.0), scale: UIScreen.main.scale) ],
                                         content:  {
                                            $0.image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .clipped()
                                         })
                                    .frame(width: 130.0, height: 130.0)
                            }

                            
                            
                            Spacer()
                            if self.isPartyActive {
                                HStack {
                                    Button(action: {
                                        print("rewind button pressed")
                                        currentPlayingIndex = currentPlayingIndex - 1
                                        //remoteCheck()
                                        remote().playerAPI?.play(queueArray[currentPlayingIndex].id, callback: defaultCallback)
                                        

                                    }) {
                                        Image(systemName: "backward.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.purple)
                                            .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                            .padding(.top, -15)
                                    }
                                    
                                    Button(action: {
                                        print("play/pause button pressed")
                                        remoteCheck()
                                        if isPlaying {
                                            remote().playerAPI?.pause(defaultCallback)
                                            print("pause")
                                            isPlaying = false
                                        } else {
                                            remote().playerAPI?.resume(defaultCallback)
                                            print("play")
                                            isPlaying = true
                                        }
                                        
                                        
                                    }) {
                                        Image(systemName: "playpause.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.purple)
                                            .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                            .padding(.top, -15)
                                    }
                                    
                                    Button(action: {
                                        //remoteCheck()
                                        print("fast forward button pressed")
                                        currentPlayingIndex = currentPlayingIndex + 1
                                        remote().playerAPI?.play(queueArray[currentPlayingIndex].id, callback: defaultCallback)
                                        
                                    }) {
                                        Image(systemName: "forward.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.purple)
                                            .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                            .padding(.top, -15)
                                    }
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

func remote() -> SPTAppRemote{
    
    var appRemote: SPTAppRemote? {
            get {
                return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
            }
        }
    return appRemote!
}

func remoteCheck() {
    if !remote().isConnected {
        print("remote not connected")
    } else {
        print("remote already connected")
    }
}

var defaultCallback: SPTAppRemoteCallback {
        get {
            print("yo")
            return {success, error in
                if let error = error {
                    print(error)
                } else {
                    print(success.debugDescription)
                }
            }
        }
    }


func refreshQueue(array: [Song]) -> [Song] {
    var refreshedArray = [Song]()
    for song in array {
        let songIndex = array.firstIndex(of: song)
        refreshedArray[songIndex!-1] = song
        
    }
    return refreshedArray
}


//MARK: - SPTAppRemotePlayerStateDelegate
func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
    print("player state changed")
}

private func getPlayerState() {
        remote().playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }

            let playerState = result as! SPTAppRemotePlayerState
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
        QueueView(currentPlayingIndex: 0, searchText: "", isLoading: false, code: "")
    }
}

