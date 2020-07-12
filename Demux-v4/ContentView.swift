//
//  ContentView.swift
//  Demux
//
//  Created by Seena Shafai on 25/06/2020.
//

import SwiftUI
import Alamofire

struct ContentView: View {

    let userInfoEndpoint = "https://api.spotify.com/v1/me/"
    let redirectURI = "demux://callback/"
    @State var text: String
    @State var joinCode: String

    var body: some View {
        NavigationView {
            VStack {
                WelcomeText()
                
                //Transition to search view
                NavigationLink(destination: SongSearchView(searchText: text)) {
                    Text("Search for a song?")
                }

                NavigationLink(destination: QueueView(currentPlayingIndex: 0, searchText: text, isLoading: true, code: "")) {
                    Text("Host a party")
                        .fontWeight(.bold)
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                            .padding(10)
                    }
                TextField("Enter join code", text: $joinCode)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    

                NavigationLink(destination: VotingView()) {
                
                    Text("Join party")
                        .fontWeight(.bold)
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                            .padding(10)
                    
                }
                    
                }
            }
        }
    }



//struct ContentView_Previews: PreviewProvider {
//    @State var text: String
//    static var previews: some View {
//        ContentView(text: )
//    }
//}

struct WelcomeText: View {
    var body: some View {
        Text("Demux")
            .foregroundColor(Color.white)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}
