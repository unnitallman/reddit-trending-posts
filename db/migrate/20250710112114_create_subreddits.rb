class CreateSubreddits < ActiveRecord::Migration[8.0]
  def change
    create_table :subreddits do |t|
      t.string :name
      t.string :display_name
      t.text :description
      t.integer :subscribers
      t.string :url

      t.timestamps
    end
  end
end
