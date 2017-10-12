# This function extracts custom facts from userdata
# Add custom_facts={fact_data} to EC2 userdata
# fact_data should be a base64 encoded json string
#

Puppet::Functions.create_function(:'clgxutil::get_userdata_customfacts') do

  dispatch :get do
  end

  require 'net/http'
  require "base64"
  require "json"

  def get()

    userdata_text = ""
    begin
      userdata_text = Net::HTTP.get('169.254.169.254', '/latest/user-data')
    rescue
      # Any errors probably mean we are not on EC2
      nil
    end


    matches = /custom_facts=([a-zA-Z0-9=]+)/.match(userdata_text)
    if matches then
      begin
        combined = Hash[]
        decoded = Base64.decode64(matches[1])
        json_decoded = JSON.parse(decoded)

        # construct return Hash that can be used with create_resources
        json_decoded.each do |name, value|
          combined[name] = Hash["name" => name, "value" => value]
        end
        combined
      rescue
        call_function('warning', 'clgxutil::get_userdata_customfacts could not decode userdata json')
        nil
      end
    end
  end
end
