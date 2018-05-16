require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class GoogleChromeIdentity < Omniauth::Strategies::OAuth2

      args [:client_id]

      option :name, "google_chrome_identity"

      option :client_options, {
        site:          'https://accounts.google.com',
        authorize_url: '/o/oauth2/auth',
        token_url:     '/o/oauth2/token'
      }

      extra do
        hash = {}
        hash['raw_info'] = raw_info unless skip_info?
        prune! hash
      end

      info do
        prune!({
          name:       raw_info['name'],
          email:      raw_info['verified_email'] ? raw_info['email'] : nil,
          first_name: raw_info['given_name'],
          last_name:  raw_info['family_name'],
          image:      image_url(options),
          urls:       {
            'Google' => raw_info['link']
          }
        })
      end

      uid do
        raw_info['id']
      end

      def request_phase
        fail "Nope"
      end

      def callback_phase
        if !request.params['access_token'] || request.params['access_token'].to_s.empty?
          raise ArgumentError.new("No access token provided.")
        end

        self.access_token = build_access_token
        self.access_token = self.access_token.refresh! if self.access_token.expired?

        self.env['omniauth.auth'] = auth_hash

        call_app!

       rescue ::OAuth2::Error => e
         fail!(:invalid_credentials, e)
       rescue ::MultiJson::DecodeError => e
         fail!(:invalid_response, e)
       rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
         fail!(:timeout, e)
       rescue ::SocketError => e
         fail!(:failed_to_connect, e)
      end

      protected

      def build_access_token
        ::OAuth2::AccessToken.from_hash(client, {
          access_token:  request.params['access_token'],
          header_format: 'OAuth %s',
          param_name:    'access_token'
        })
      end

      private

      def image_url(options)
        original_url = raw_info['picture']
        return original_url if original_url.nil? || (!options[:image_size] && !options[:image_aspect_ratio])

        image_params = []
        if options[:image_size].is_a?(Integer)
          image_params << "s#{options[:image_size]}"
        elsif options[:image_size].is_a?(Hash)
          image_params << "w#{options[:image_size][:width]}" if options[:image_size][:width]
          image_params << "h#{options[:image_size][:height]}" if options[:image_size][:height]
        end
        image_params << 'c' if options[:image_aspect_ratio] == 'square'

        params_index = original_url.index('/photo.jpg')
        original_url.insert(params_index, ('/' + image_params.join('-')))
      end

      def prune!(hash)
        hash.delete_if do |_, v|
          prune!(v) if v.is_a?(Hash)
          v.nil? || (v.respond_to?(:empty?) && v.empty?)
        end
      end

      def raw_info
        @raw_info ||= access_token.get('https://www.googleapis.com/oauth2/v2/userinfo').parsed
      end

    end
  end
end
