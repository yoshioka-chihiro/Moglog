class Meal < ApplicationRecord
  belongs_to :end_user
  has_many :meal_details,  dependent: :destroy
  has_many :foods, through: :meal_details
  
  #関連付けしたmeal_detailモデルを一緒にデータ保存できるようにする
  accepts_nested_attributes_for :meal_details, reject_if: :all_blank, allow_destroy: true

  validates :meal_type, presence: true
  validates :record_time, presence: true

  enum meal_type: { breakfast: 0, lunch: 1, dinner: 2, nash:3 }


end
