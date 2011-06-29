class PostsController < ApplicationController
  before_filter :authenticated
  # GET /posts
  # GET /posts.xml
  def index
    @posts = Post.order("created_at DESC").all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create
    params[:post]["user_id"] = session[:user_id]
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to(@post, :notice => 'Post was successfully created.') }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])
    if @post.user_id == session[:user_id]
      params[:post]["user_id"] = session[:user_id]
      respond_to do |format|
        if @post.update_attributes(params[:post])
          format.html { redirect_to(@post, :notice => 'Post was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html {render :partial => "shared/permission_denied"}
        format.json  { render :json => "Permission denied"}
        format.xml  { render :xml => {"value" => "Permission denied"}}
      end   
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    if @post.user_id == session[:user_id]
      @post.destroy

      respond_to do |format|
        format.html { redirect_to(posts_url) }
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html {render :partial => "shared/permission_denied"}
        format.json  { render :json => "Permission denied"}
        format.xml  { render :xml => {"value" => "Permission denied"}}
      end   
    end  
  end
end
