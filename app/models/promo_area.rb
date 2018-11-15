class PromoArea < ApplicationRecord
  belongs_to :topic_category

  mount_uploader :image, HeaderUploader
end
