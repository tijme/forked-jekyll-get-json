require "jekyll"
require 'json'
require 'deep_merge'
require 'open-uri'

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

          uri = d['json'].sub("://", "://#{username}:#{token}@")
          puts uri
          
          contents = URI.open(uri)
          puts contents
          
          source = JSON.load(contents)
          puts source

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

