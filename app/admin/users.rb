ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :avatar, 
      :avatar_cache, :birthdate, :gender, :t_shirt_size, 
      :first_name, :last_name,
      :address_zip, :address_country, :address_state, :address_city,
      :address_line_1, :address_line_2, :open_for_follow,
      track_ids: [], release_ids: [],
      artist_info_attributes: [:id, :image, :bio_short, :bio_long, :facebook, :twitter, 
      :instagram, :video, :genre, :user, :_destroy],
      videos_attributes: [:id, :title, :video_link, :user, :_destroy],
      users_roles_attributes: [:id, :user, :role_id, :assigned_to, :_destroy]

  jcropable

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :roles, as: :select, collection: proc { Role.all }

  index do
    selectable_column
    id_column
    column :email
    column "Name" do |user|
      user.name
    end
    column "Role" do |user|
      user.roles.pluck(:name).join(', ')
    end
    column "Subscription", :subscription_length
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column "Reports" do |user|
      user.reports.count
    end
    column "Points" do |user|
      user.points
    end
    column "Badges" do |user|
      images = ""

      user.badges.each do |badge|
        images << "<img src='#{badge.image.url}' class='small-avatar' title='#{badge.name}'>"  
      end

      images.html_safe
    end
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions
    
    f.inputs do
      f.input :avatar, hint: image_tag(f.object.avatar.url(:thumb)), as: :jcropable
      f.input :avatar_cache, as: :hidden
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation

      if current_user.has_role?(:admin)
        # f.input :roles, as: :check_boxes
        f.has_many :users_roles, allow_destroy: true do |ur|
          ur.input :role
          if ur.object.role && ur.object.role.name == 'handler' || ur.object.new_record?
            ur.input :assigned_to, as: :select, label: "Assigned to Artist",
                collection: User.with_role(:artist).map {|a| [a.name, a.id] }
          end
        end
        f.input :braintree_subscription_expires_at, as: :date_time_picker
      end
      f.input :open_for_follow
      f.input :address_zip
      f.input :address_country, as: :string
      f.input :address_state
      f.input :address_city
      f.input :address_line_1
      f.input :address_line_2
      f.input :birthdate, as: :date_time_picker
      f.input :gender
      f.input :t_shirt_size
      f.input :releases
      f.input :tracks
    end

    f.inputs do
      f.has_many :artist_info, allow_destroy: true do |s|
        image = s.object.image.present? ? image_tag(s.object.image.url, style: "background-color: gray;") : ''
        s.input :bio_short
        s.input :bio_long
        s.input :facebook
        s.input :twitter
        s.input :instagram
        s.input :genre
        s.input :image, hint: image, as: :jcropable
        s.input :image_cache, as: :hidden
      end
    end

    f.inputs do
      f.has_many :videos, allow_destroy: true do |s|
        s.input :title
        s.input :video_link
      end
    end

    f.actions
  end

  controller do
    def update
      if params[:user][:password].blank?
        params[:user].delete "password"
        params[:user].delete "password_confirmation"
      end

      super
    end

    def apply_pagination(chain)
        chain = super unless formats.include?(:json) || formats.include?(:csv)
        chain
    end
  end

  csv do
    column :email
    column "Name" do |user|
      user.name
    end
    column "Role" do |user|
      user.roles.pluck(:name).join
    end
    column :subscription_length
    column :braintree_subscription_expires_at
    column :created_at
    column "Reports" do |user|
      user.reports.count
    end
    column "Badges" do |user|
      user.badges.pluck(:name).join(', ')
    end
  end
end

ActiveAdmin.register ArtistInfo do
  menu false
  jcropable
end