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
            Divider()
            ScrollView(.horizontal) {
                HStack(spacing: 30) {
                    ForEach(queueArray) { index in
                        VotingItem(currentSong: index, isVoted: false, imageURL: index.albumImage)
                    }
                }.padding()
            }.frame(height: 300)
           // Divider()
            //Spacer()
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
