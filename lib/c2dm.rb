require 'typhoeus'

# Google Cloud To Device Messaging Service
class C2DM
  AUTH_URL = 'https://www.google.com/accounts/ClientLogin'
  PUSH_URL = 'https://android.apis.google.com/c2dm/send'

  @@auth_token = ENV["C2DM_AUTH_TOKEN"]
  @@source = ENV["C2DM_SOURCE"] || "Company-AppName-1.0"

  class << self
    # Call this if you haven't set ENV["C2DM_AUTH_TOKEN"] || C2DM_AUTH_TOKEN
    # It sets @auth_token on C2DM
    #
    # +email+ => Your Google Account email for this application
    # +password => Your password
    def authorize(email, password)
      post_body = "accountType=HOSTED_OR_GOOGLE&Email=#{email}&Passwd=#{password}&service=ac2dm&source=#{@source}"
      params = {
        :body => post_body,
        :headers => {
          'Content-type' => 'application/x-www-form-urlencoded',
          'Content-length' => "#{post_body.length}"
        }
      }
      response = Typhoeus::Request.post(AUTH_URL, params)
      @auth_token = response.body.split("\n")[2].gsub("Auth=", "")
    end

    # Send a notification
    #
    # :registration_id is required.
    # :collapse_key is optional.
    #
    # Other +options+ will be sent as "data.<key>=<value>"
    #
    # +options+ = {
    #   :registration_id => "...",
    #   :message => "Hi!",
    #   :extra_data => 42,
    #   :collapse_key => "some-collapse-key"
    # }
    def send_notification(options)
      hydra = Typhoeus::Hydra.new
      hydra.queue request(options)
      hydra.run
    end

    def request(options)
      payload = {}
      payload[:registration_id] = options.delete(:registration_id)
      payload[:collapse_key] = options.delete(:collapse_key)
      options.each {|key, value| payload["data.#{key}"] = value}

      Typhoeus::Request.new(PUSH_URL, {
        :method => :post,
        :params   => payload,
        :headers  => {
          'Authorization' => "GoogleLogin auth=#{@auth_token}"
        }
      })
    end

    # Send multiple notifications
    #
    # +notifications+ = [
    #   {
    #     :registration_id => "...",
    #     :payload => {...},
    #     :collapse_key => "..."
    #   },
    #   ...
    # ]
    def send_notifications(notifications)
      notifications.map do |notification|
        send_notification(notification)
      end
    end

    def auth_token
      @auth_token
    end

    def auth_token=(token)
      @auth_token = token
    end

    def source
      @source
    end

    def source=(new_source)
      @source = new_source
    end
  end
end
