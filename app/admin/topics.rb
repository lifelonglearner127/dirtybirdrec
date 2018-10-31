ActiveAdmin.register Topic do

  permit_params :title, :body, :category_id, :pinned, :locked, :noteworthy, :see_to_all

	index do
		column :id
		column :title
		column :body
		column :user
		column :pinned
		column :locked
		column :created_at
		column :category
		column :noteworthy
		actions do |release|
    end
	end
end
