# config/initializers/sidekiq.rb

# Start the scheduled job when the application starts
Rails.application.config.after_initialize do
  # Only start the job if we're in a web process (not in console, rake, etc.)
  if defined?(Rails::Server) || defined?(Puma)
    puts "🚀 Starting Reddit posts fetch scheduler..."
    FetchRedditPostsJob.perform_later
  end
end 