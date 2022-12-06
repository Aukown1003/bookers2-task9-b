class UsersController < ApplicationController
  before_action :authenticate_user!

  # 現在のuser_idと投稿者のidが一致していないとはじく
  before_action :ensure_correct_user, only: [:update]

  def show
    # week_ago_to = 1.week.ago.end_of_day
    # week_ago_from = (week_ago_to - 6.day).at_beginning_of_day
    # to = Time.current.at_end_of_day
    # from = (to - 6.day).at_beginning_of_day
    # yesterday = (to - 1.day)
    
    @user = User.find(params[:id])
    @books = @user.books
    @book = Book.new
    @book_count_today = @books.created_day(0).count
    @book_count_yesterday = @books.created_day(1).count
    @book_count_current_week = @books.count_current_week.count
    @book_count_last_week = @books.count_last_week.count
    # @book_count_today = @books.where(created_at: Time.current.at_beginning_of_day..to).count 
    # @book_count_yesterday = @books.where(created_at: yesterday.at_beginning_of_day..yesterday.at_end_of_day).count
    # @book_count_current_week = @books.where(created_at: from..to).count
    # @book_count_last_week = @books.where(created_at: week_ago_from..week_ago_to).count
  end

  def index
    @users = User.all
    @book = Book.new
    # endなし
  end
  
  def search
    
  end

  def edit
    @user = User.find(params[:id])
    if @user.id != current_user.id
      redirect_to user_path(current_user.id)
    end
  end

  def update
    # @user定義なし
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:notice] = "You have updated user successfully."
      redirect_to user_path(@user.id)
    else
      # render editに戻す
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to user_path(current_user)
    end
  end

  def currect_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
  end
end
