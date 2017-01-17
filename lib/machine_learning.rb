require 'bundler/setup'
require 'active_record'

require "machine_learning/version"
require "machine_learning/classification"
require "machine_learning/twitter/client"
require "machine_learning/models/tweet"
require "machine_learning/models/unigram"

ActiveRecord::Base.logger = Logger.new(STDERR)

ActiveRecord::Base.establish_connection({
  adapter: 'sqlite3',
  database: 'db/machine_learning.sqlite'
})

module MachineLearning
  SMILEYS = {
    ':)' => true,
    ':(' => false,
    ':D' => true,
    ':\'(' => false,
  }.freeze

  def self.db_reset
    FileUtils.rm 'db/machine_learning.sqlite' rescue nil
    ActiveRecord::Schema.define do
      create_table :tweets do |t|
        t.string :tweet
        t.boolean :positive
        t.boolean :unigramified, default: false
      end

      create_table :unigrams do |t|
        t.string :unigram
        t.integer :count, default: 0
        t.boolean :positive
      end
    end
  end

  def self.db_migrate
    ActiveRecord::Schema.define do
    end
  end

  def self.db_setup
    db_reset
    db_seed
  end

  def self.db_seed
    client = MachineLearning::Twitter::Client.new

    SMILEYS.each do |smiley, sentiment|
      client.search(smiley, 10, sentiment)
    end
  end

  def self.unigramify_tweets
    MachineLearning::Tweet.where(unigramified: false).find_in_batches.each do |tweets|
      tweets.each do |tweet|
        MachineLearning::Tweet.transaction do
          tweet.unigrams.map(&->(k,v) { MachineLearning::Unigram.create_or_update(k, v, tweet.positive) })
          tweet.update_column(:unigramified, true)
        end
      end
    end
  end
end
