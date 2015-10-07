class AddViewCountColumnToArticles < ActiveRecord::Migration
  def change
  	add_column :articles, :view_count, :integer
  end
end
