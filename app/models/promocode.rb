class Promocode < ApplicationRecord
  enum promo_type: [:eggs, :insider, :vib]
  belongs_to :user, foreign_key: "applied_to", optional: true

  validates :value, :promo_type, presence: true

  before_save :apply_code

  def apply_code
    if self.applied_to_was == nil && self.applied_to_changed?
      case promo_type
      when 'eggs'
        user.increment!(:download_credits, value.to_i)
      when 'insider'
        nil
      when 'vib'
        nil
      end

      self.apply_date = DateTime.now
    end
  end
end
