class HomeController < ApplicationController
  def index
    service = RedditTrendingService.new
    @trending_posts = service.fetch_trending_posts
  end
end
