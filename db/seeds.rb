Cuisine.create!(name: "Inventory")
Cuisine.create!(name: "Japanese")
Cuisine.create!(name: "Thai")
Cuisine.create!(name: "Italian")
Cuisine.create!(name: "Chinese")
Cuisine.create!(name: "Korean")
Cuisine.create!(name: "Vietnamese")
Cuisine.create!(name: "Indian")
Cuisine.create!(name: "Indonesian")
Cuisine.create!(name: "Western")
Cuisine.create!(name: "Mexican")


User.create!(name:	"Site Administrator",
             email: "admin@cityproduce.com",
						 customerid: "ADMIN",
						 admin: true,
						 cuisine: "Inventory",
						 password:              "password",
						 password_confirmation: "password",
						 activated: true,
						 activated_at: Time.zone.now)
						 
User.create!(name:	"Ken Abramson",
             email: "kenneth.abramson@gmail.com",
						 customerid: "KENA",
						 admin: true,
						 cuisine: Cuisine.find_by(id: rand(2..Cuisine.all.size)).name,
						 password:              "password",
						 password_confirmation: "password",
						 activated: true,
						 activated_at: Time.zone.now)

User.create!(name:	"Mark Hidaka",
             email: "mark@cityproduce.com",
						 customerid: "MTH",
						 admin: true,
						 cuisine: Cuisine.find_by(id: rand(2..Cuisine.all.size)).name,
						 password:              "password",
						 password_confirmation: "password",
						 activated: true,
						 activated_at: Time.zone.now)
