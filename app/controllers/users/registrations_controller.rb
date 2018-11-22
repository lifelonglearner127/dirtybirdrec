class Users::RegistrationsController < Devise::RegistrationsController
  
  before_action :set_notifications#, only: [:edit]
  prepend_before_action :authenticate_scope!, only: [:edit_profile, :edit_account, :update_account, :update_profile, :destroy]
  prepend_before_action :set_minimum_password_length, only: [:edit_profile, :edit_account]

  def new
    countries = JSON.parse(File.read(Rails.root.join('app/assets/countries.json')))
    @countries = countries.map {|k,v| [v,k] }.sort
    super
  end

  def edit_profile
    render :edit_profile
  end

  def update_profile
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = resource.update_without_password(account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      bypass_sign_in resource, scope: resource_name
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def edit_account
    render :edit_account
  end

  def update_account
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    existing_profile_url_user = User.where(profile_url: account_update_params[:profile_url])
    if !existing_profile_url_user.any? or (existing_profile_url_user.any? and existing_profile_url_user.first.id == current_user.id)
      resource_updated = resource.update_with_password(account_update_params)
      yield resource if block_given?
      if resource_updated
        if is_flashing_format?
          flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
            :update_needs_confirmation : :updated
          set_flash_message :notice, flash_key
        end
        bypass_sign_in resource, scope: resource_name
        respond_with resource, location: after_update_path_for(resource)
      else
        clean_up_passwords resource
        set_minimum_password_length
        redirect_to usr_edit_account_path(resource)
      end
    else
        clean_up_passwords resource
        set_minimum_password_length
        redirect_to usr_edit_account_path(resource), :flash => { :alert => "Profile Url already exists" }
    end
  end

  # DELETE /resource
  def destroy
    resource.soft_delete
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed
    yield resource if block_given?
    redirect_to after_sign_out_path_for(resource_name)
  end  

  protected

  def after_sign_up_path_for(resource)
    choose_profile_path(anchor: 'step-2')
  end

  def update_resource(resource, params)
    if resource.provider.present?
      resource.update_without_password(params) 
    else
      resource.update_with_password(params)
    end
  end

  private

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :t_shirt_size, :birthdate, :gender, :address_line_1, :address_line_1, :address_country, :address_city, :address_state, :address_zip, :profile_url, :header_id)
  end

end
