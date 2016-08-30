require 'rest-client'
begin
  require 'airbrake'
rescue LoadError
  warn 'Install airbrake gem to correctly log exceptions.'
end

module OmniAuth
  class Reportbee
    class << self
      def do_esf_api_call( args )
        api_response_hash = {}
        api_url_string = args[:api_url_string]
        access_token_object = args[:access_token_object]
        raise 'No access token object received. Cannot make API call.' if access_token_object.blank?

        source_params = args.fetch(:source_params, {})
        is_post_request = args.fetch(:is_post_request, false)

        # encode api_url_string to url string, because api_url_string is normal string here with spaces and special characters also.
        url_string = URI.encode( api_url_string )

        header_hash = { 'Accept' => 'reportbee/esf.version.v2' }
        options = { body: source_params, headers: header_hash }

        # do api call
        api_response_hash = is_post_request ? access_token_object.post( url_string, options ) : access_token_object.get( url_string, options )
        api_response_hash.parsed
      rescue ::OAuth2::Error => e
        error_message = "OAuth2 Error while Making ESF API call from omniauth-rb gem. API URL: #{api_url_string}. Error message: #{e.message}. Error code: innutritious."

        if defined?( Rails ) && Rails.env.development?
          puts '===================== Exception occurred ====================='
          puts error_message
          puts '=============================================================='
        else
          if defined?( Airbrake ) && ::Airbrake.send(:configured?, :default)
            ab_hash = { error_class: 'ESF API Call', error_message: error_message, url_string: api_url_string,
                        error_code: e.code, error_description: e.description, response_hash: e.response }
            ::Airbrake.notify( e, ab_hash )
          end
        end

        false_response_hash( error_message )
      rescue StandardError => e
        error_message = "Error while Making ESF API call from omniauth-rb gem. API URL: #{api_url_string}. Error message: #{e.message}. Error code: unfunniness."

        if defined?( Rails ) && Rails.env.development?
          puts '===================== Exception occurred ====================='
          puts error_message
          puts '=============================================================='
        else
          if defined?( Airbrake ) && ::Airbrake.send(:configured?, :default)
            ab_hash = { error_class: 'ESF API Call', error_message: error_message, url_string: api_url_string, response_hash: api_response_hash }
            ::Airbrake.notify( e, ab_hash )
          end
        end

        false_response_hash( error_message )
      end

      def do_app2app_api_call( args )
        response = {}
        api_url_string = args[:api_url_string]
        access_token_object = args[:access_token_object]
        raise 'No access token object received. Cannot make API call.' if access_token_object.blank?

        source_params = args.fetch(:source_params, {})
        is_post_request = args.fetch(:is_post_request, false)

        source_params.merge!( access_token: access_token_object.token )

        api_url = URI.escape( api_url_string )
        uri = URI.parse( api_url )

        http = Net::HTTP.new( uri.host, uri.port )

        if 'https' == APP_CONFIG[:protocol] || api_url_string.include?( 'https' )
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        request = is_post_request ? Net::HTTP::Post.new(uri.request_uri) : Net::HTTP::Get.new( uri.request_uri )
        request.set_form_data( source_params )
        request['Accept'] = 'reportbee/esf.version.v2'
        # If debugging of requests are required, then enable the following line.
        # http.set_debug_output($stdout) if Rails.env.development?

        response = http.request( request )

        raise 'No response received' unless response.present?
        raise "Wrong response code #{response.code} received" unless '200' == response.code

        response.body
      rescue StandardError => e
        error_message = "Error while Making App2App API call from omniauth-rb gem. API URL: #{api_url_string}. Error message: #{e.message}. Error code: pedestaled."

        if defined?( Rails ) && Rails.env.development?
          puts '===================== Exception occurred ====================='
          puts error_message
          puts '=============================================================='
        else
          if defined?( Airbrake ) && ::Airbrake.send(:configured?, :default)
            ab_hash = { error_class: 'App2App API Call', error_message: error_message, url_string: api_url_string, response_hash: response }
            ::Airbrake.notify( e, ab_hash )
          end
        end

        false_response_hash( error_message )
      end

      def get_client_credentials_access_token_object
        oauth_client.client_credentials.get_token
      end

      def get_access_token_object( access_token_string, refresh_token_string, expires_at )
        acc_token = ::OAuth2::AccessToken.new( oauth_client, access_token_string, {refresh_token: refresh_token_string, expires_at: expires_at} )
        acc_token.expired? ? acc_token.refresh! : acc_token
      end

      private

      def oauth_client
        @oauth_client ||= ::OAuth2::Client.new( ENV['OAUTH_APP_ID'], ENV['OAUTH_APP_SECRET'], :site => ENV['OAUTH_APP_URL'] )
      end

      def false_response_hash( message = 'All parameters not sent' )
        status = false
        { 'status' => status, 'message' => message }
      end
    end
  end
end
