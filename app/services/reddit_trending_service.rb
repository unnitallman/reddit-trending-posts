# app/services/reddit_trending_service.rb
require 'httparty'

class RedditTrendingService
  BASE_URL = 'https://www.reddit.com/r/all/hot.json?limit=50'

  def fetch_trending_posts
    response = HTTParty.get(BASE_URL, headers: { 'User-Agent' => 'RailsRedditTrendsApp/0.1' })
    return [] unless response.success?
    parse_posts(response.parsed_response)
  end

  private

  def parse_posts(api_response)
    api_response.dig('data', 'children').map do |child|
      data = child['data']
      {
        title: data['title'],
        author: data['author'],
        subreddit: data['subreddit'],
        score: data['score'],
        upvote_ratio: data['upvote_ratio'],
        comments_count: data['num_comments'],
        url: "https://reddit.com#{data['permalink']}",
        reddit_id: data['id'],
        post_created_at: Time.at(data['created_utc'])
      }
    end
  end
end 