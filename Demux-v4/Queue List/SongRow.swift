//
//  SongView.swift
//  Demux-v4
//
//  Created by Seena Shafai on 02/07/2020.
//

import SwiftUI

struct SongRow: View {
    var song: Song
    
    var body: some View {
        HStack {
            Text(song.name)
            Text(song.artist)
            Text(song.album)
            Spacer()
        }
    }
}

