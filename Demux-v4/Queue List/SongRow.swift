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

struct SongRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            SongRow(song: TestData.LSF)
//                .previewLayout(.fixed(width: 300, height: 70))
//            SongRow(song: TestData.reasonIsTreason)
//                .previewLayout(.fixed(width: 300, height: 70))
//            SongRow(song: TestData.shootTheRunner)
//                .previewLayout(.fixed(width: 300, height: 70))
        }
    }
}
