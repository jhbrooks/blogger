class AddCreatedByColumnToArticles < ActiveRecord::Migration
  def change
  	add_column :articles, :created_by, :string
  end
end
