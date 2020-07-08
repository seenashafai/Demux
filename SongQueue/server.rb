# server.rb
require 'sinatra'
require 'mongoid'
require 'json'
require 'uri'

#DB Setup
Mongoid.load! "mongoid.config"

#Models
class Song
  include Mongoid::Document

  #Set up input fields
  field :id, type: String
  field :name, type: String
  field :artist, type: String
  field :album, type: String

  validates :id, presence: true
  validates :name, presence: true
  validates :artist, presence: true
  validates :album, presence: true
end

#Default endpoint
get '/' do
  'Welcome to the Song Queue!'
end

#Set global content type
before do
  content_type 'application/json'
end

#Helper to assign base url
helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://{request.env['HTTP_HOST']}"
    end

    #define custom json decoder
    def json_params
      begin
#        jsonBody = URI.decode_www_form_component(request.body.read)
#        p jsonBody
        JSON.parse(request.body.read)
      rescue
        halt 400, { message:'Invalid JSON' }.to_json
      end
    end
  end

#Get all songs
get '/songs' do
  Song.all.to_json
end

#Add a song
post '/songs' do
    song = Song.new(json_params)
    if song.save
      #Return location of new song
      response.headers['Location'] = "#{base_url}/songs/#{song.id}"
      status 201 #Success
    else
      status 422 #Fail
    end
end
