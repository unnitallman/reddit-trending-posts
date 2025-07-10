class Subreddit < ApplicationRecord
  has_many :reddit_posts, dependent: :destroy
end
