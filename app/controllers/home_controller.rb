class HomeController < ApplicationController
  def index
    @trending_posts = RedditPost.includes(:subreddit)
                               .order(score: :desc)
                               .limit(50)
    
    # If no posts in database, fetch live data as fallback
    if @trending_posts.empty?
      service = RedditTrendingService.new
      @trending_posts = service.fetch_trending_posts
    end
  end

  def trigger_fetch
    FetchRedditPostsJob.perform_later
    redirect_to root_path, notice: "Reddit posts fetch job has been queued!"
  end

  def job_status
    @jobs = Sidekiq::Queue.new.size
    @stats = Sidekiq::Stats.new
    render json: {
      queued_jobs: @jobs,
      processed_jobs: @stats.processed,
      failed_jobs: @stats.failed
    }
  end
end
