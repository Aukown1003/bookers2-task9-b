class BooksController < ApplicationController
  before_action :authenticate_user!

  def show
    @book = Book.find(params[:id])
    # @user = @book.user ←不要　何故か？showの部分テンプレートで@user = @book.userにして渡せばいい
    @book_comment = BookComment.new
  end

  def index
    # Time.current(現在日時の取得)
    # beginning_of_week週初めの情報(https://railsdoc.com/page/date_related)
    from = Time.current.beginning_of_week
    # end_of_week週終わりの情報
    to = Time.current.end_of_week
    # これにcreated_atを足したい
    # @books = Book.includes(:favorited_users).sort {|a,b| b.favorited_users.size <=> a.favorited_users.size}
    # これは一週間内に作成されたいいねにソートがかかるので、一週間内にいいねしたもの一覧になる
    @books = Book.includes(:favorited_users).where(favorites: {created_at: Time.current.all_week}).sort {|a,b| b.favorited_users.size <=> a.favorited_users.size}
    # @books = Book.includes(:favorited_users).sort{|a,b|b.favorited_users.where(created_at: from..to).size <=> a.favorited_users.where(created_at: from..to).size}
    # @books = Book.find(Favorite.group(:book_id).where(created_at: Time.current.all_week).order('count(book_id) desc').pluck(:book_id))
    # @bookにインスタンス作成
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
    user_id = @book.user.id
    if user_id != current_user.id
      redirect_to books_path
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render 'edit'
    end
  end

  # deleteはmethod
  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title,:body)
  end
end
