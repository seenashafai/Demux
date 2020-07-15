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
    
    let song = Song()
    let session = Session()
    var playerState: SPTAppRemotePlayerState?

    @State var currentPlaying = Song()
    @State var currentPlayingIndex: Int
    @State var isPlaying = Bool()
    @State var isPartyActive = Bool()
    @State var subscribedToPlayerState = Bool()
    
    @State var searchText: String
    @State var queueArray = [Song]()
    @State var currentSong = Song()
    @State var showingAlert = false
    @State var isLoading: Bool
    @State var code: String
    @State var showingPlayer = false
    
    @State var sliderValue: Double = 0
    @State var maxSliderValue: Double = 0

    var body: some View {
        ZStack {
            VStack {
                Text("Join code: \(code)")
                HStack {
                    
                //Filtering
                Text("Search queue")
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
                //Search bar
                SearchBar(text: $searchText)

                //Searchbar filtering
                List(queueArray.filter({ searchText.isEmpty ? true : $0.name.contains(searchText) })) { song in
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
                    //Delete from queue & refresh
                    song.removeFromQueue(song: currentSong) { song in
                        queueArray = song
                        Session.globalSession.queue = queueArray
                    }

                    //Clear search bar
                    searchText = ""
                }, secondaryButton: .cancel())
            }
            }.onAppear {
                isLoading = true
                song.loadQueue() { songItem in
                    queueArray = songItem
                    Session.globalSession.queue = queueArray
                    isLoading = false
                    code = session.randomString()
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
                                //MARK: - START
                                Text("Start party")
                                    .padding(.top, 15)
                                Button(action: {
                                    print("Start Party")
                                    remote().authorizeAndPlayURI(queueArray[0].id)
                                    
                                    print(currentPlaying.name, currentPlayingIndex, queueArray)
                                    isPlaying = true
                                    isPartyActive = true
                                    
                                }) {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .font(.largeTitle)
                                        .foregroundColor(.green)
                                        .padding(.top, 10)
                                }
                            } else {
                                //MARK: - STOP
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
                                Text("Now playing: \(queueArray[0].name)")
                                    .foregroundColor(.black)
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
                            }

                            
                            
                            Spacer()
                            if self.isPartyActive {
                                HStack {
                                    Button(action: {
                                        //MARK: - REWIND
                                        print("rewind button pressed")
                                        currentPlayingIndex = currentPlayingIndex - 1
                                        print(currentPlaying.name, currentPlayingIndex, queueArray)
                                        remote().playerAPI?.play(queueArray[currentPlayingIndex].id, callback: defaultCallback)
                                        

                                    }) {
                                        Image(systemName: "backward.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.purple)
                                            .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                            .padding(.top, -15)
                                    }
                                    
                                    Button(action: {
                                        //MARK: - PLAY/PAUSE
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
                                        //MARK: - FAST FORWARD

                                        print("fast forward button pressed")
                                        song.loadQueue() { songItem in
                                            queueArray = songItem
                                            song.removeFromQueue(song: queueArray[0]) { song in
                                            queueArray = song
                                            Session.globalSession.queue = queueArray
                                            
                                            remote().playerAPI?.play(queueArray[0].id, callback: defaultCallback)

                                            }
                                        }


                                        
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

func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
    print("changed poo")
}

func remoteCheck() {
    remote().playerAPI?.subscribe(toPlayerState: defaultCallback)

    if !remote().isConnected {
        print("remote not connected")
    } else {
        print("remote already connected")
    }
}

func getNextSong(array: [Song]) -> Song
{
    print(array.debugDescription, "bruh")
    return array.max()!
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

func playNext() -> [Song] {
    let song = Song()
    var queue = [Song]()
    print(Session.globalSession.queue, "gC")
    song.removeFromQueue(song: Session.globalSession.queue![0]) { song in
        queue = song
        remote().playerAPI?.play(queue[0].id, callback: defaultCallback)
        
    }
    return queue
}

//Generate join code
func randomString() -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let joinCode = String((0..<5).map{ _ in letters.randomElement()! })
    Session.globalSession.joinCode = joinCode

    return joinCode
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QueueView(currentPlayingIndex: 0, searchText: "", isLoading: false, code: "")
            QueueView(currentPlayingIndex: 0, searchText: "", isLoading: false, code: "")
        }
    }
}


