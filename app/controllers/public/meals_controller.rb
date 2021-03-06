class Public::MealsController < ApplicationController
  before_action :authenticate_end_user!
  before_action :correct_end_user, only: [:show, :edit, :update]

  def index
    # 今日の００：００
    start_date = Time.current.beginning_of_day
    # 今日の２３：５９
    end_date = Time.current.end_of_day
    # ログイン中ユーザーのMealを取得
    @user_meals = Meal.where(end_user_id: current_end_user.id)
    # その中から今日の記録を取得
    @today_meals_list = @user_meals.where(record_time: start_date..end_date)
    # 食事検索用
    @q = Meal.ransack(params[:q])
    # 食事登録用
    @meal = Meal.new
    # mealに紐付くmeal_detailsをbuildしておく（追加ボタン用）
    @meal_detail = @meal.meal_details.build
    # カロリー合計表示用
    @today_calorie_sum = 0
    @today_meals_list.each do |meal|
      meal.meal_details.each do |meal_detail|
        @today_calorie_sum += meal_detail.calorie_subtotal
      end
    end
  end

  def search
    @user_meals = Meal.where(end_user_id: current_end_user.id)
    # :qはransackのデフォルトキーなので変更しない
    @q = @user_meals.ransack(params[:q])
    # (distinct: true)によりresultの重複をなくしてくれている
    @results = @q.result(distinct: true).order(record_time: :asc).page(params[:page]).per(8)
  end

  def create
    @meal = Meal.new(meal_params)
    if @meal.save
      redirect_to meal_path(@meal), notice: "食事を投稿しました！"
    else
      @q = Meal.ransack(params[:q])
      # 今日の００：００
      start_date = Time.current.beginning_of_day
      # 今日の２３：５９
      end_date = Time.current.end_of_day
      # ログイン中ユーザーのMealを取得
      @user_meals = Meal.where(end_user_id: current_end_user.id)
      # その中から今日の記録を取得
      @today_meals_list = @user_meals.where(record_time: start_date..end_date)
      render :index, alert: "登録できませんでした。お手数ですが、入力内容をご確認のうえ再度お試しください"
    end
  end

  def show
    @meal_details = @meal.meal_details
    @calorie_sum = 0
    @protein_sum = 0
    @carbohydrate_sum = 0
    @fat_sum = 0
    @fiber_sum = 0
  end

  def edit
  end

  def update
    if @meal.update(meal_params)
      flash[:notice] = "食事内容を更新しました。"
      redirect_to meal_path(@meal)
    else
      flash[:alret] = "更新に失敗しました。"
      render :edit
    end
  end

  def destroy
    @meal = Meal.find(params[:id])
    if @meal.destroy
      flash[:notice] = "食事を削除しました"
      redirect_to meals_path
    else
      flash[:notice] = "食事を削除しました"
      render :index
    end
  end

  private

  def meal_params
    params.require(:meal).permit(
      :meal_type,:record_time,
      meal_details_attributes:[:id, :meal_id, :food_id, :quantity, :_destroy])
      .merge(end_user_id: current_end_user.id)
  end

  def correct_end_user
    @meal = Meal.find(params[:id])
    @end_user = @meal.end_user
    # ログイン中のユーザーではないまたは退会済みユーザーの場合はアクセスできない
    redirect_to(root_path) unless @end_user == current_end_user || (current_end_user.is_deleted == true)
  end

end
