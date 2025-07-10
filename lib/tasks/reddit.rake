namespace :reddit do
  desc "Fetch trending posts from Reddit and store in database"
  task fetch_posts: :environment do
    puts "🔄 Fetching trending posts from Reddit..."
    
    service = RedditTrendingService.new
    posts = service.fetch_trending_posts
    
    if posts.empty?
      puts "❌ No posts fetched from Reddit API"
      exit 1
    end
    
    puts "📊 Found #{posts.length} trending posts"
    
    # Clear existing posts if requested
    if ENV['CLEAR_EXISTING'] == 'true'
      puts "🗑️  Clearing existing posts..."
      RedditPost.delete_all
      Subreddit.delete_all
    end
    
    posts_created = 0
    posts_updated = 0
    
    posts.each do |post_data|
      # Find or create subreddit
      subreddit = Subreddit.find_or_create_by(name: post_data[:subreddit]) do |s|
        s.display_name = post_data[:subreddit]
        s.description = "Subreddit for #{post_data[:subreddit]}"
        s.subscribers = 0
        s.url = "https://reddit.com/r/#{post_data[:subreddit]}"
      end
      
      # Find or create post
      post, created = RedditPost.find_or_create_by(reddit_id: post_data[:reddit_id]) do |p|
        p.title = post_data[:title]
        p.author = post_data[:author]
        p.subreddit = subreddit
        p.score = post_data[:score]
        p.upvote_ratio = post_data[:upvote_ratio]
        p.comments_count = post_data[:comments_count]
        p.url = post_data[:url]
        p.created_at = post_data[:post_created_at]
      end
      
      if created
        posts_created += 1
      else
        # Update existing post with latest data
        post.update!(
          title: post_data[:title],
          score: post_data[:score],
          upvote_ratio: post_data[:upvote_ratio],
          comments_count: post_data[:comments_count]
        )
        posts_updated += 1
      end
    end
    
    puts "✅ Successfully processed posts:"
    puts "   📝 Created: #{posts_created}"
    puts "   🔄 Updated: #{posts_updated}"
    puts "   📊 Total posts in database: #{RedditPost.count}"
    puts "   📂 Total subreddits: #{Subreddit.count}"
  end
  
  desc "Clear all posts and subreddits from database"
  task clear_posts: :environment do
    puts "🗑️  Clearing all posts and subreddits..."
    RedditPost.delete_all
    Subreddit.delete_all
    puts "✅ Database cleared"
  end
  
  desc "Show database statistics"
  task stats: :environment do
    puts "📊 Database Statistics:"
    puts "   📝 Total posts: #{RedditPost.count}"
    puts "   📂 Total subreddits: #{Subreddit.count}"
    puts "   👤 Unique authors: #{RedditPost.distinct.count(:author)}"
    puts "   🔥 Highest score: #{RedditPost.maximum(:score)}"
    puts "   💬 Most comments: #{RedditPost.maximum(:comments_count)}"
    
    puts "\n🏆 Top 5 posts by score:"
    RedditPost.order(score: :desc).limit(5).each do |post|
      puts "   #{post.score} pts - #{post.title[0..50]}... (r/#{post.subreddit.name})"
    end
  end
end
