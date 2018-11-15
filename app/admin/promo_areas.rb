# frozen_string_literal: true

ActiveAdmin.register PromoArea do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  config.filters = false

  permit_params :image, :url, :topic_category_id

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      if action_name == 'new'
        f.input :topic_category_id, as: :select, multiple: true,
                                    collection: TopicCategory.where('id NOT IN (?)', PromoArea.all.pluck(:topic_category_id)).map { |tc| [tc.title.to_s, tc.id] }
      else
        f.input :topic_category_id, as: :select,
                                    collection: TopicCategory.where('id NOT IN (?)', PromoArea.all.pluck(:topic_category_id)).map { |tc| [tc.title.to_s, tc.id] }
      end
      f.input :url
      f.input :image, as: :file
    end

    f.actions
  end

  controller do
    def promo_area_params
      params.require(:promo_area).permit(:image, :url, topic_category_id: [])
    end

    def create
      promo_area_params[:topic_category_id].each do |tp_id|
        promo_area = PromoArea.where(topic_category_id: tp_id)

        if promo_area.present?
          promo_area.update(image: promo_area_params[:image], url: promo_area_params[:url])
        else
          promo_area.create(image: promo_area_params[:image],
                            url: promo_area_params[:url],
                            topic_category_id: tp_id)
        end
      end

      redirect_to collection_url
    end
  end
end
