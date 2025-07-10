class FetchRedditPostsJob < ApplicationJob
  queue_as :default

  def perform
    puts "🔄 FetchRedditPostsJob: Starting scheduled fetch..."
    
    # Run the rake task
    Rake::Task['reddit:fetch_posts'].invoke
    
    # Reschedule the job to run again in 5 minutes
    FetchRedditPostsJob.set(wait: 5.minutes).perform_later
    
    puts "✅ FetchRedditPostsJob: Completed and rescheduled for 5 minutes from now"
  rescue => e
    puts "❌ FetchRedditPostsJob: Error occurred - #{e.message}"
    # Still reschedule even if there's an error
    FetchRedditPostsJob.set(wait: 5.minutes).perform_later
  end
end
