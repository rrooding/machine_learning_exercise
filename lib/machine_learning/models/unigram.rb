module MachineLearning
  class Unigram < ActiveRecord::Base
    scope :positive, -> { where(positive: true) }
    scope :negative, -> { where(positive: false) }

    def self.create_or_update(unigram, count, positive)
      u = where(unigram: unigram, positive: positive).first_or_create
      u.increment(:count, count).save
    end

    def self.score_for(scope, unigram)
      (scope.where(unigram: unigram).first.try(:count).to_i + 1).to_f
    end

    def self.distinct_count
      select(:unigram).distinct.count
    end
  end
end
