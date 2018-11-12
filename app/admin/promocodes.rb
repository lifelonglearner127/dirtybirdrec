ActiveAdmin.register Promocode do
  config.filters = false
  
  permit_params :slug, :value, :promo_type, :user, :applied_to

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions
    
    f.inputs do
      f.object.slug ||= SecureRandom.hex(4)
      f.input :slug, hint: 'keep or change to unique string'
      f.input :promo_type
      f.input :value, hint: 'days or eggs count'
      f.input :user
    end

    f.actions
  end
end
