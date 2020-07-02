//
//  ContentView.swift
//  Demux
//
//  Created by Seena Shafai on 25/06/2020.
//

import SwiftUI
import Alamofire



struct ContentView: View {

    var appdelegate = AppDelegate()
    var scenedelegate = SceneDelegate()
    let SpotifyClientID = "f9c4ab38a6fa40a1bdfc3f5ad8156d1e"
    let userInfoEndpoint = "https://api.spotify.com/v1/me/"
    let authToken = "BQCsjDENnLBUn0g59Zcox2p3wuHYLqV7LCzSRyBK_SFGvpLhM-TCHPR-xcIVberjtfdCAGCOW-Oiuh77Ojqqjq-kuSd_2dh5Er8dEkViN1fRMCMU9a0c2vr_Qc8Gbdqxu5bizpZ9WDHWULnRG21KGyJxeMcpO8raV4yBSMZhxCZtp8M-6Rf75MeCAN6XkyvV4QyFZ_w-fPf9l7SSEHZYcNm0VFpltKZAi4_yTfv31yhXaHIUYtzN0fXYzCN8hcuRDBGzsnLsqR4jMdg"
    let redirectURI = "demux://callback/"

    var body: some View {
        VStack {
            WelcomeText()
            Button(action: {
                print(Session.globalSession.authToken, "authToken")
                
            }) {
                Text("Host a party")
                    .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .padding(10)
                }
            Button(action: {
                print(scenedelegate.appRemote.connectionParameters.accessToken, "aT")
                
            }) {
                Text("Join a party")
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



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct WelcomeText: View {
    var body: some View {
        Text("Demux")
            .foregroundColor(Color.white)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}
