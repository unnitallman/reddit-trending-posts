class CreateRedditPosts < ActiveRecord::Migration[8.0]
  def change
    create_table :reddit_posts do |t|
      t.string :title
      t.string :author
      t.references :subreddit, null: false, foreign_key: true
      t.integer :score
      t.decimal :upvote_ratio
      t.integer :comments_count
      t.string :url
      t.string :reddit_id

      t.timestamps
    end
  end
end
