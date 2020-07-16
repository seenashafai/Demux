//
//  VotingItem.swift
//  Demux-v4
//
//  Created by Seena Shafai on 12/07/2020.
//

import SwiftUI
import URLImage

struct VotingItem: View {
    
    let song = Song()
    @State var currentSong = Song()
    @State var isVoted: Bool
    @State var imageURL: String
        
    var body: some View {
        VStack {
            ZStack {
                //Album image
                URLImage(URL(string: imageURL)!,
                         processors: [ Resize(size: CGSize(width: 100.0, height: 100.0), scale: UIScreen.main.scale) ],
                         content:  {
                            $0.image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                         }) .frame(width: 270, height: 270)
                
            }
            Text(currentSong.name)
            HStack {
                Button(action: {
                    if isVoted {
                        self.isVoted = false
                        currentSong.votes = currentSong.votes - 1
                    } else {
                        self.isVoted = true
                        currentSong.votes = currentSong.votes + 1
                    }
                    song.addVote(song: currentSong)
                }) {
                    if isVoted {
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                            .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                            .padding(.top, -15)
                    } else {
                        Image(systemName: "hand.thumbsup")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                            .padding(.top, -15)

                    }
                }
                Text(String(currentSong.votes))
            }
        }
    }
}


