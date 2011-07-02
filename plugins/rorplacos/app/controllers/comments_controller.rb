class CommentsController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    params[:comment]["user_id"] = session[:user_id]
    @comment = @post.comments.create(params[:comment])
    redirect_to post_path(@post)
  end
end

