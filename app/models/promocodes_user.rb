class PromocodesUser < ApplicationRecord
  belongs_to :promocode, inverse_of: :promocodes_users
  belongs_to :user, inverse_of: :promocodes_users

  before_save :apply_code

  validate :expiration_date_cannot_be_in_the_past

  private

    def apply_code
      case promocode.promo_type
      when 'eggs'
        user.increment!(:download_credits, promocode.value.to_i)
      when 'insider'
        nil
      when 'vib'
        nil
      end
    end

    def expiration_date_cannot_be_in_the_past
      if promocode.expiration_date.present? && promocode.expiration_date < Date.today
        errors.add(:expiration_date, "is in the past")
      end
    end
end
