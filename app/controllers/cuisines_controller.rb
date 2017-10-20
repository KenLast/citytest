class CuisinesController < ApplicationController
  def new
		@cuisine = Cuisine.new
  end

  def create
		name = params[:cuisine][:name].to_s
		name.strip!
		@cuisine = Cuisine.new
		@cuisine.name = name
		if @cuisine.name.nil? || @cuisine.name.empty?
			flash[:danger] = "nothing entered"
			redirect_to new_cuisine_path and return
		end
		@cuisine.name.capitalize!
		if @cuisine.save
			flash[:success] = "#{@cuisine.name} successfully created"
		else
#			flash[:danger] = "#{@cuisine.name} template creation failed.  #{@cuisine.errors.messages}"
			flash[:danger] = "#{@cuisine.name} template creation failed.   #{@cuisine.errors.details[:name][0][:value]} #{@cuisine.errors.messages[:name][0]}"
			redirect_to new_cuisine_path and return
		end
		redirect_to cuisines_path
  end

  def index
		@cuisines = Cuisine.all.paginate(page: params[:page])
  end
	
	private
		def cuisine_params
		  params.require(:cuisine).permit(:name)
		end
end
