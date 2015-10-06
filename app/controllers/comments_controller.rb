class CommentsController < ApplicationController
	include CommentsHelper

	def create
		@comment = Comment.new(comment_params)
		@comment.article_id = params[:article_id]
		@comment.save
		flash.notice = "New comment created by '#{@comment.author_name}'"

		redirect_to article_path(@comment.article)
	end
end
