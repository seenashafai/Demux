//
//  VotingView.swift
//  Demux-v4
//
//  Created by Seena Shafai on 12/07/2020.
//

import SwiftUI

struct VotingView: View {
    
    let song = Song()
    @State var queueArray = [Song]()
    @State var counter = 0
    
    var body: some View {
        VStack {
            Text("Join code: \(Session.globalSession.joinCode ?? "TEST1")")
                .font(.title)
            Spacer()
            ScrollView(.horizontal) {
                HStack(spacing: 30) {
                    ForEach(queueArray) { index in
                        VotingItem(currentSong: index, isVoted: false, imageURL: index.albumImage)
                    }
                }.padding()
            }.frame(height: 300)
            NavigationLink(destination: SongSearchView(searchText: "")) {
                Text("Search for a song")
                    .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .padding(.top, 50)
            }

        }.onAppear {
            song.loadQueue() { songs in
                queueArray = songs
            }
        }
    }
}





struct VotingView_Previews: PreviewProvider {
    static var previews: some View {
        VotingView()
    }
}
