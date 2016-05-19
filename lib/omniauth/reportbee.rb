require 'rest-client'

module OmniAuth
  class Reportbee
    def self.do_api_call( api_url_string, access_token_string, source_params = {}, post_request = false )
      # encode api_url_string to url string, because api_url_string is normal string here with spaces and special characters also.
      url_string = URI.encode( api_url_string )

      access_token_string = get_client_credentials_access_token if access_token_string.blank?
      access_token_object = get_access_token_object( access_token_string )

      header_hash = { 'Accept' => 'reportbee/esf.version.v2' }
      options = { body: source_params, headers: header_hash }

      # do api call
      api_response_hash = post_request ? access_token_object.post( url_string, options ) : access_token_object.get( url_string, options )
      response_hash = { response_hash: api_response_hash.parsed, access_token_string: access_token_string }

      response_hash
    rescue => e
      api_response_hash = false_response_hash("Something went wrong while doing api calls! #{e.message}")
      response_hash = { response_hash: api_response_hash, access_token_string: access_token_string }

      response_hash
    end

    def self.get_client_credentials_access_token
      url = ENV['OAUTH_APP_URL'] + '/oauth/token'
      client_id = ENV['OAUTH_APP_ID']
      client_secret = ENV['OAUTH_APP_SECRET']

      options = { grant_type: 'client_credentials', client_id: client_id, client_secret: client_secret }
      response = RestClient.post( url, options )

      response_hash = JSON.parse( response )
      response_hash['access_token']
    end

    def self.get_access_token_object( access_token_string )
      oauth_client = ::OAuth2::Client.new( ENV['OAUTH_APP_ID'], ENV['OAUTH_APP_SECRET'], :site => ENV['OAUTH_APP_URL'] )

      ::OAuth2::AccessToken.new( oauth_client, access_token_string )
    end

    def self.false_response_hash( message = 'All parameters not sent' )
      status = false
      { 'status' => status, 'message' => message }
    end
  end
end