# Demux
Spotify for parties: An app to allow users to queue music to the host's Spotify account. The queue can be voted on by other users, and songs will be moved around the queue accordingly

### Front-end (Swift)
Dependencies:
- Alamofire
- AlamofireImage
- SwiftyJSON
- URLImage

(Will try to phase out these dependencies once everything is working; they can all be replicated with native code)

Frameworks:
- SpotifyiOS

### Back-end (Ruby)
Uses a custom Ruby/Sinatra API and a MongoDB database to view and add songs
Shotgun dependency allows for real-time reloading of server during development process

Dependencies:
- Sinatra
- Mongoid
- Shotgun

### Notes
Xcode is currently set to allow unsecure http communication in Info.plist: 'App Transport Security Settings -> Allow Arbitrary Loads = true'
This is to allow for local debugging of the API during development. For release, the API will have to be hosted on a dedicated server, and this setting can be set back to false/removed altogether
