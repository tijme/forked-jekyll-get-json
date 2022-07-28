require "jekyll"
require 'json'
require 'deep_merge'
require 'open-uri'
require "uri"
require "net/http"
require "base64"

module JekyllGetJson
  class GetJsonGenerator < Jekyll::Generator
    safe true
    priority :highest

    def generate(site)

      config = site.config['jekyll_get_json']
      if !config
        warn "No config".yellow
        return
      end
      if !config.kind_of?(Array)
        config = [config]
      end

      config.each do |d|
        begin
          target = site.data[d['data']]
          username = ENV['JEKYLL_GITHUB_USERNAME']
          token = ENV['JEKYLL_GITHUB_TOKEN']

          url = URI(d['json'])

          https = Net::HTTP.new(url.host, url.port)
          https.use_ssl = true

          request = Net::HTTP::Get.new(url)
          request["Authorization"] =  "Basic " + Base64::encode64("#{username}:#{token}").strip

          response = https.request(request)
          source = response.read_body
          

          if target
            target.deep_merge(source)
          else
            site.data[d['data']] = source
          end
        rescue
          next
        end
      end
    end
  end
end

