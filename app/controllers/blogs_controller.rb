class BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :edit, :update, :destroy]


  # GET /blogs
  # GET /blogs.json
  def index
    
    @github = Github.new
    @github2 = @github.repos.languages user: 'ninja247' repo: 'DevcampPortfolio'
    @blogs = Blog.all
  end


  def languages(*args)
    arguments(args, required: [:user, :repo])

    response = get_request("/repos/#{arguments.user}/#{arguments.repo}/languages", arguments.params)
    return response unless block_given?
    response.each { |el| yield el }
  end




  def list(*args)
    arguments(args) do
      permit %w[ user org type sort direction since ]
    end
    params = arguments.params
    unless params.symbolize_keys[:per_page]
      params.merge!(Pagination.per_page_as_param(current_options[:per_page]))
    end

    response = if (user_name = params.delete('user') || user)
      get_request("/users/#{user_name}/repos", params)
    elsif (org_name = params.delete('org') || org)
      get_request("/orgs/#{org_name}/repos", params)
    elsif args.map(&:to_s).include?('every')
      get_request('/repositories', params)
    else
      # For authenticated user
      get_request('/user/repos', params)
    end
    return response unless block_given?
    response.each { |el| yield el }
  end









  # GET /blogs/1
  # GET /blogs/1.json
  def show
  end

  # GET /blogs/new
  def new
    @blog = Blog.new
  end

  # GET /blogs/1/edit
  def edit
  end

  # POST /blogs
  # POST /blogs.json
  def create
    @blog = Blog.new(blog_params)

    respond_to do |format|
      if @blog.save
        format.html { redirect_to @blog, notice: 'Blog was successfully created.' }
        format.json { render :show, status: :created, location: @blog }
      else
        format.html { render :new }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /blogs/1
  # PATCH/PUT /blogs/1.json
  def update
    respond_to do |format|
      if @blog.update(blog_params)
        format.html { redirect_to @blog, notice: 'Blog was successfully updated.' }
        format.json { render :show, status: :ok, location: @blog }
      else
        format.html { render :edit }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blogs/1
  # DELETE /blogs/1.json
  def destroy
    @blog.destroy
    respond_to do |format|
      format.html { redirect_to blogs_url, notice: 'Blog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog
      @blog = Blog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def blog_params
      params.require(:blog).permit(:title, :body)
    end

end
