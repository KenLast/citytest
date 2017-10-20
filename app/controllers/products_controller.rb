class ProductsController < ApplicationController
	before_action :logged_in_user
	before_action :admin_user, only: [:update, :destroy, :inventory, :add]


  def new
		@user = current_user
		debugger
  end

  def create
  end

	def show
	end
	
	def index
		debugger
	end
	
  def edit
  end

	# note: Order customerid: ADMIN is the inventory

	# called by administrator to update the whole inventory
  def inventory
		@user = User.find_by(customerid: "ADMIN")
		@order = @user.orders.first
		@product = Product.new()
		@products = User.find_by(customerid: "ADMIN").orders.first.products

	#	debugger
	end

	# called by administrator to add product to inventory
	def add
		@user = User.find_by(customerid: "ADMIN")
		@order = @user.orders.first
		@product = @order.products.build(product_params)
		debugger
		if @product.save
			flash[:success] = "#{@product.productid.to_s} added to inventory"
		else
			flash[:danger] = "#{@product.productid.to_s} not added to inventory"
		end
		redirect_to inventory_path
	end
	
	# called by administrator to modify a product in inventory
	def update
		@user = User.find_by(customerid: "ADMIN")
		@order = @user.orders.first
	#	debugger
	end
	
	# called by administrator to remove a product from inventory
	def destroy
		@user = User.find_by(customerid: "ADMIN")
		@order = @user.orders.first
	#	debugger
	end
	
	private
	
		def product_params
			params.require(:product).permit(:quantity, :productid, :selum)
		end
	
end
