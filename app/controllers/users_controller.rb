class UsersController < ApplicationController
	before_action :logged_in_user, only: [ :show, :index, :edit, :update, :destroy, :new]
	before_action :correct_user, only: [:edit, :update, :show]
	before_action :admin_user, only: [:index, :destroy, :new]

	def index
#		@users = User.paginate(page: params[:page])
		cuisine = params[:cuisine]
		if cuisine.nil?
			@users = User.all
		else
			@users = User.where(cuisine: cuisine)
			@cuisine = cuisine
		end
#		debugger
	end
	
	def purge
		@users = User.all
	end

	
  def show
    @user = User.find_by(id: (params[:id]))
#		@orders = @user.orders.paginate(page: params[:page])
		@orders = @user.orders
		if @user.customerid == "ADMIN"
			@cuisine_history = "all"
		end

#		debugger
  end
	
  def new
	  @user = User.new
  end
	
	def create
	  @user = User.new(user_params)    # only allow permitted params

		newid = @user.customerid.upcase
		xuser = User.find_by(customerid: newid)
		if !xuser.blank?
			flash[:error] = "Duplicate Customer ID.  Someone already has #{newid.to_s}."
			redirect_back(fallback_location: admin_path) and return
		end

		if @user.save
			#
			# Handle a successful save.
			# show a new signup form
      # note: purposely NOT logging in the newly created user or
			# sending activation email because Mark will create all users
			# So users will automatically be activated on creation

			# @user.send_activation_email           # this is not necessary on this app
			@user.activate													# KDA activate immediately
      flash[:success] = "#{@user.name} successfully created"
			redirect_to signup_path
		else
		  render 'new'
		end
	end
	
	def edit
		@user = User.find(params[:id])
	end
	
	def update
		@user =  User.find(params[:id])
		
		# check for duplicate customerid to avoid exception
		newid = user_params[:customerid].upcase
		if newid != @user.customerid
			xuser = User.find_by(customerid: newid)
			if !xuser.blank?
				flash[:error] = "Duplicate Customer ID.  Someone already has #{newid.to_s}."
				redirect_back(fallback_location: admin_path) and return
			end
		end
		
		
    if @user.update_attributes(user_params)
      # Handle a successful update.
			flash[:success] = "Profile updated"
			if (@user.customerid == current_user.customerid)
				 redirect_to @user and return
			else
			   redirect_to users_path and return
			end
		else
			# something went wrong.  redisplay the page
      render 'edit'
    end
  end
	
  def destroy
	  dead_name = User.find(params[:id]).name
    User.find(params[:id]).destroy
#		debugger
    flash[:success] = "User #{dead_name} deleted"
		redirect_back(fallback_location: admin_path) and return
  end


	private
	
	  def user_params
      params.require(:user).permit(:name, :customerid, :email, :password,
                                   :password_confirmation, :cuisine)
		end

    # Before filters

		
    # Confirms the correct user.
    def correct_user
			@user = User.find_by(id: (params[:id]))
			if !@user
				flash[:danger] = "That page does not exist"
				redirect_to(root_url)
			end

		  flash_text = "Must be owner to perform this action."
			flash[:danger] = flash_text unless (current_user?(@user) || current_user.admin?)
      redirect_to(root_url) unless (current_user?(@user) || current_user.admin?)
    end
end
