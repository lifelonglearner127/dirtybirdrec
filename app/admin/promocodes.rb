ActiveAdmin.register Promocode do
  config.filters = false
  
  permit_params :slug, :value, :promo_type, :expiration_date, user_ids: []
  index do
    column 'Slug', sortable: :slug do |p|
      link_to p.slug, admin_promocodes_users_path(q: {promocode_id_eq: p.id})
    end
    column 'Users count', sortable: :users_count do |p|
      p.users.count
    end
    column :promo_type
    column :value
    column :expiration_date
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions

    f.inputs do
      f.object.slug ||= SecureRandom.hex(4)
      expired = promocode.expiration_date.present? && promocode.expiration_date < Date.today ? 'expired!' : ''
      f.input :slug, hint: 'keep or change to unique string'
      f.input :expiration_date, as: :date_time_picker, hint: expired
      f.input :promo_type
      f.input :value, hint: 'days or eggs count'
      f.input :users
    end

    f.actions
  end

  action_item :promocodes_users do
    link_to "Users promocodes", admin_promocodes_users_path
  end

  controller do
    def scoped_collection
      super.includes :users
      super.joins('LEFT JOIN "promocodes_users" ON "promocodes_users"."promocode_id" = "promocodes"."id"')
           .select('promocodes.*, COUNT(promocodes_users.id) as users_count')
           .group('promocodes.id')
    end
  end
end
