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
                //TODO: - add guard statement for accesstoken...
                AF.request(userInfoEndpoint, method: .get, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer "+Session.globalSession.authToken!]).responseJSON { response in
                    print(response.debugDescription)
                    //Decode response as JSON
                    if let result = response.value {
                        let JSON = result as! NSDictionary
                        print(JSON)
                    }
                }

                
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
