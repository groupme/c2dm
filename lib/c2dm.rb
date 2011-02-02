require 'typhoeus'

class C2DM
  AUTH_URL = 'https://www.google.com/accounts/ClientLogin'
  PUSH_URL = 'https://android.apis.google.com/c2dm/send'

  @@auth_token = ENV["C2DM_AUTH_TOKEN"] || C2DM_AUTH_TOKEN

  class << self
    # Call this if you haven't set ENV["C2DM_AUTH_TOKEN"] || C2DM_AUTH_TOKEN
    # It sets @auth_token on C2DM
    #
    # +email+ => Your Google Account email for this application
    # +password => Your password
    def authorize(email, password)
      post_body = "accountType=HOSTED_OR_GOOGLE&Email=#{email}&Passwd=#{password}&service=ac2dm"
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

    # Send a single notification
    #
    # +payload+ will be prefixed with data.<key>
    # e.g. +payload+ = {:foo => 1, :bar => 2} = "data.foo=1&data.bar=2"
    def send_notification(registration_id, payload, collapse_key = nil)
      data = {}
      payload.each {|key, value| data["data.#{key}"] = value}
      params = {
        :body => { :registration_id => registration_id },
        :headers => { 'Authorization' => "GoogleLogin auth=#{@auth_token}" }
      }
      params[:body].merge(data)
      params[:body][:collapse_key] = collapse_key if collapse_key

      Typhoeus::Request.post(PUSH_URL, params)
    end

    # Send multiple notifications
    #
    # +notifications+ = [
    #     {
    #       :registration_id => "...",
    #       :payload => {...},
    #       :collapse_key => "..."
    #     },
    #     ...
    # ]
    def send_notifications(notifications)
      notifications.map do |notification|
        send_notification(
          notification[:registration_id],
          notification[:payload],
          notification[:collapse_key]
        )
      end
    end

    def auth_token
      @auth_token
    end
  end
end
