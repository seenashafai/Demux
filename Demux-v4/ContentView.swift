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
                
                TextField("Enter join code", text: $joinCode)
                    .padding(7)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .frame(width: 195, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    

                NavigationLink(destination: VotingView()) {
                
                    Text("Join party")
                        .fontWeight(.bold)
                            .font(.title)
                            .padding()
                            .padding(.horizontal, 15)

                            .background(Color.green)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                            .padding(.bottom, 80)
                            .padding(.top, -15)
                        
                    
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
            //.padding(.top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(text: "", joinCode: "")
    }
}
