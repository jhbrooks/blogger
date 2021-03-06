class ArticlesController < ApplicationController
	include ArticlesHelper
	
	before_filter :require_login, only: [:new, :create, :destroy]
	before_filter :author_matches_current_user, only: [:edit, :update]

	def index
		@articles = Article.all
	end

	def show
		@article = Article.find(params[:id])
		@comment = Comment.new
		@comment.article_id = @article.id

		@article.up_count
		@article.save
	end

	def new
		@article = Article.new
	end

	def create
		@article = Article.new(article_params)
		@article.author_id = current_user.id
		@article.created_by = current_user.username
		@article.view_count = 0
		@article.save
		flash.notice = "Article '#{@article.title}' created!"

		redirect_to article_path(@article)
	end

	def destroy
		@article = Article.find(params[:id])
		deleted_tag_names = []
		@article.tags.each do |tag|
			if !(Tagging.where(tag_id: tag.id).where.not(article_id: @article.id).exists?)
				deleted_tag_names << tag.name
				tag.destroy
			end
		end
		@article.destroy

		if deleted_tag_names == []
			flash.notice = "Article '#{@article.title}' deleted!"
		else
			flash.notice = "Article '#{@article.title}' deleted! Also deleted the following empty tags: #{deleted_tag_names.join(", ")}"
		end

		redirect_to articles_path
	end

	def edit
		@article = Article.find(params[:id])
	end

	def update
		@article = Article.find(params[:id])
		old_tag_names = @article.tag_list.split(", ")
		old_article_title = @article.title

		@article.update(article_params)
		new_tag_names = @article.tag_list.split(", ")

		threatened_tag_names = old_tag_names - new_tag_names
		threatened_tags = Tag.where(name: threatened_tag_names)
		deleted_tag_names = []
		threatened_tags.each do |tag|
			if !(Tagging.where(tag_id: tag.id).where.not(article_id: @article.id).exists?)
				deleted_tag_names << tag.name
				tag.destroy
			end
		end

		if deleted_tag_names == []
			flash.notice = "Article '#{old_article_title}' updated!"
		else
			flash.notice = "Article '#{old_article_title}' updated! Also deleted the following empty tags: #{deleted_tag_names.join(", ")}"
		end

		redirect_to article_path(@article)
	end

	private

	def author_matches_current_user
		@article = Article.find(params[:id])
		unless @article.author && current_user && @article.author == current_user
	        redirect_to article_path(@article)
	        flash.notice = "An article may only be edited by its author!"
	        return false
	    end
	end
end
