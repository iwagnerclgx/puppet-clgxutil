# This function extracts custom facts from userdata
# Add custom_facts={fact_data} to EC2 userdata
# fact_data should be a base64 encoded json string
#

Puppet::Functions.create_function(:'clgxutil::get_userdata_customfacts') do

  dispatch :get do
  end

  require 'net/http'

  def get()

    begin
      $text = Net::HTTP.get('169.254.169.254', '/latest/user-data')
    rescue
      # Any errors probably mean we are not on EC2
      nil
    end

    $matches = /custom_facts=([a-zA-Z0-9]+=)/.match($text)
    if $matches then
      begin
        $decoded = Base64.decode64($matches[1])
        JSON.parse($decoded)
      rescue
        warning("Error in parsing userdata json")
        nil
      end
    end
  end
end
