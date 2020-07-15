//
//  SongSearchView.swift
//  Demux-v4
//
//  Created by Seena Shafai on 04/07/2020.
//

import SwiftUI

struct SongSearchView: View {
    
    let song = Song()
    
    @State var searchText: String
    @State var songArray = [Song]()
    @State var showingAlert = false
    @State var currentSong: Song?
    
    var body: some View {
        VStack{
            Text("Search for a song...")
                .font(.system(size: 30, weight: .black, design: .default))
                .padding(-20)
            SearchBar(text: $searchText)
            Spacer()
            
            Button(action: {
                //Init query and token for track search
                //songArray.removeAll()
                let query = searchText
                let authToken = Session.globalSession.authToken
                //API request for song results
                song.search(query: query, authToken: authToken!) { songs in
                    songArray = songs
                }
            }) {
                Text("Search")
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .padding(.horizontal, 15)
                    .padding(.vertical, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .padding(5)
                }
            List(songArray) { song in
                Button(action: {
                    print(songArray)
                print("alert")
                    print(song.id)
                    self.showingAlert = true
                    currentSong = song
                }) {
                    SongRow(song: song)
                }.alert(isPresented: self.$showingAlert) {
                    Alert(title: Text(song.name), message:Text("You are about to add this song to the queue"), primaryButton: .default(Text("Add to Queue")) {
                        //Add to queue
                        song.addToQueue(song: song)
                        //Clear search bar and results
                        searchText = ""
                        songArray.removeAll()

                    }, secondaryButton: .cancel())
                }
            }
        }
    }
}


struct SongSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SongSearchView(searchText: "Song...")
    }
}
