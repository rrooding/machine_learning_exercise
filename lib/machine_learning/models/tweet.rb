module MachineLearning
  class Tweet < ActiveRecord::Base
    scope :positive, -> { where(positive: true) }
    scope :negative, -> { where(positive: false) }

    def self.ppb
      @ppb ||= self.prior_probability(self.positive)
    end

    def self.npb
      @npb ||= self.prior_probability(self.negative)
    end

    def unigrams
      h = Hash.new(0)
      sanitized.each { |u| h.store(u, h[u]+1) }
      h
    end

    private

    def self.prior_probability(scope)
      scope.count.to_f / all.count.to_f
    end

    def sanitized
      self.tweet.downcase.gsub(/(@\S*|http\S*|')/, '').split(/\W/) - [""]
    end
  end
end
