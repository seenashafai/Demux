# Demux
Spotify for parties: An app to allow users to queue music to the host's Spotify account. The queue can be voted on by other users, and songs will be moved around the queue accordingly

# Front-end
Dependencies:
- Alamofire
- SwiftyJSON

Frameworks:
- SpotifyiOS

# Back-end
Uses a custom sinatra API and a MondoDB database to view and add songs
Shotgun dependency allows for real-time reloading of server during development process

Dependencies:
- sinatra
- mongoid
- shotgun

