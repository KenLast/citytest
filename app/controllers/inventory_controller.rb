require 'csv'

class InventoryController < ApplicationController
	before_action :admin_user, only: [:new, :create, :show, :view]

	# display form to get the newest inventory
	def new
	# if :name parameter is present, then pass it in as the cuisine type
		if !params[:name].nil?
			@name = params[:name]
		end
	end

	# POST from new
  def create
		uploaded_io = params[:csvfile]
		
		# do some error checking on file name
		if uploaded_io.nil?
			flash[:danger] = "Must select a file to load"
			redirect_to inventory_path and return
		end
		
		if uploaded_io.original_filename.length < 5
			flash[:danger] = "Must be a .CSV file"
			redirect_to inventory_path and return
		end

		if uploaded_io.original_filename[-4,4].upcase != ".CSV"
			flash[:danger] = "Must be a .CSV file"
			redirect_to inventory_path and return
		end
	
		fname = Rails.root.join('public', 'uploads', uploaded_io.original_filename)
		File.open(fname, 'wb') do |file|
			file.write(uploaded_io.read)
		end
		
		# now create an order for ADMIN user containing one of each non-discontinued product
		# @order = Order.new
		user = User.find_by(customerid: "ADMIN")
		cuisine = params[:template][:cuisine]
		if cuisine.nil?
			flash[:danger] = "No cuisine template"
			redirect_to inventory_path and return
		end
		name = "Template for #{cuisine}"
		note = "Automatically Generated Template"
		@order = user.orders.build(name: name, cuisine: cuisine, note: note)
		
		if CSV.open(fname, headers:true) do |product|   # open file, but use ennumerator to save much memory space
				products = product.each
				products.select do |row|       # iterate through rows
					if (row["Discontinued"].strip == "FALSE")

						@product = Product.find_by(productid: row["ProductID"])
						if @product.nil?                           # don't want to replicate products
							@product = Product.new
							@product.productid = row["ProductID"]
							@product.name = row["ProductName"].strip
							um = UM_TEXT[row["UM"].upcase]
							@product.um = um.nil? ? row["UM"].upcase : um
							qum = UM_TEXT[row["QuantityPerUnit"].upcase]
							@product.qum = qum.nil? ? row["QuantityPerUnit"].upcase : qum   # note: headings for QUM and QuantityPerUnit are reversed on City Produce spreadsheet
							@product.qpu = row["QUM"]
							@product.save
						end
						
						@order.lineitems.build(quantity: 1, product_id: @product.id, selum: @product.um)
					end
				end
			end
		else
			flash[:danger] = "Something went wrong with inventory file upload"
			redirect_to inventory_path and return
		end
		a = @order.save
		if a.nil?
			flash[:danger] = "Creation of Template for #{@order.cuisine} failed.  #{@order.errors.messages}"
			redirect_to inventory_path and return
		else
			flash.now[:success] = "Template for #{@order.cuisine} loaded successfully"
			render 'view'
		end
	end
	
	def show
	end
	
	# from show
	def view
		@cuisine = params[:template][:cuisine]
		@user = User.find_by(customerid: "ADMIN")
		@orders = @user.orders
		@order = @orders.where(cuisine: @cuisine).first
		if @order.nil?
			flash[:danger] = "Must first create inventory."
			redirect_to inventory_path and return
		end
	end

	# want to list history of inventory
	def history
		cuisine = params[:template]
		@user = User.find_by(customerid: "ADMIN")
		@orders = @user.orders.where(name: "Template for #{cuisine}")
		@cuisine_history = cuisine
	end
	

end
