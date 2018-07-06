ActiveAdmin.register Announcement do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
  permit_params :avatar, :admin_id, :release_id, :release_date, :title, :text,
  :feed_title, :bg_color

  jcropable

#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions
    
    f.inputs do
      image = f.object.avatar.present? ? image_tag(f.object.avatar.url) : '' 
      f.input :avatar, hint: image, as: :jcropable
      f.input :avatar_cache, as: :hidden
      f.input :image_uri
      f.input :title
      f.input :feed_title
      f.input :bg_color
      f.input :text, as: :froala_editor
      f.input :release_date, as: :date_time_picker
      f.input :admin, as: :select, label: "Admin",
          collection: User.with_role(:admin).map {|a| [a.name, a.id] }
    end

    f.actions
  end

end
