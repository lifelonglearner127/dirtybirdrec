class Promocode < ApplicationRecord
  enum promo_type: [:eggs, :insider, :vib]
  has_many :promocodes_users, inverse_of: :promocode
  has_many :users, through: :promocodes_users

  validates :value, :promo_type, presence: true
end
