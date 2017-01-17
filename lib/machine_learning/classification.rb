module MachineLearning
  class Classification
    attr_reader :tweet

    def initialize(tweet)
      @tweet = tweet
    end

    def positive?
      positive_score > negative_score
    end

    def negative?
      !positive?
    end

    def classification
      positive? ? :positive : :negative
    end

    # private

    def positive_score
      MachineLearning::Tweet.ppb * positive_word_score
    end

    def negative_score
      MachineLearning::Tweet.npb * negative_word_score
    end

    def positive_word_score
      word_score MachineLearning::Unigram.positive
    end

    def negative_word_score
      word_score MachineLearning::Unigram.negative
    end

    def word_score(scope)
      scoring = ->(w) { (MachineLearning::Unigram.score_for(scope, w) / ( scope.sum(:count) + MachineLearning::Unigram.distinct_count )) }
      #tokenized.collect(&scoring).reduce(&:*)
      tokenized.collect(&scoring).reduce(&:*)
    end

    def tokenized
      tweet.downcase.gsub(/(@\S*|http\S*|')/, '').split(/\W/) - [""]
    end
  end
end
