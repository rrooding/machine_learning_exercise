require 'yaml'
require 'twitter'
require 'machine_learning/models/tweet'

module MachineLearning::Twitter
  LIMIT = 100.freeze
  class Client
    attr_reader :client

    def initialize
      config = YAML.load_file('twitter.yml')
      @client = ::Twitter::REST::Client.new(config)
    end

    def search(filter, count, positive)
      puts "Searching #{filter} (positive: #{positive})"
      count.downto(0) do |n|
        @client.search("#{filter} -filter:links -rt", lang: 'en', count: LIMIT, result_type: :recent).take(LIMIT).each do |object|
          puts object.text if object.is_a?(::Twitter::Tweet)
          MachineLearning::Tweet.create(tweet: object.text, positive: positive)
        end
        sleep 10
      end
    end
  end
end
