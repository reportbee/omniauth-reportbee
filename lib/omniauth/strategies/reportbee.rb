require 'omniauth-oauth2'
module OmniAuth
  module Strategies
    class Reportbee < OmniAuth::Strategies::OAuth2
      # change the class name and the :name option to match your application name
      option :name, :reportbee

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
                                :site => ENV['OAUTH_APP_URL'],
                                :authorize_url => "#{ENV['OAUTH_APP_URL']}/oauth/authorize"
                            }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info['id'] }

      info do
        {
            :name => raw_info['name'],
            :email => raw_info['email']
        }
      end

      extra do
        {
            :is_admin => raw_info['is_admin_user'],
            :sign_in_count => raw_info['sign_in_count'],
            :last_sign_in_at => raw_info['last_sign_in_at'],
            :small_profile_picture_url => raw_info['small_profile_picture_url'],
            :medium_profile_picture_url => raw_info['medium_profile_picture_url'],
            :is_email_verified => raw_info['is_email_verified'],
            :is_mobile_verified => raw_info['is_mobile_verified'],
            :is_current_user_profile_present => raw_info['is_current_user_profile_present']
        }
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def raw_info
        @raw_info ||= access_token.get('/users/me.json').parsed
      end
    end
  end
end