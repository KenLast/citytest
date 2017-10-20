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



99.times do |n|
  name  = Faker::Name.name
  email = "customer-#{n+1}@example.org"
  password = "password"
  User.create!(name:  name,
               email: email,
							 customerid: "CUST#{n+104}",
							 admin: false,
							 cuisine: Cuisine.find_by(id: rand(2..Cuisine.all.size)).name,
               password:              password,
               password_confirmation: password,
							 activated: true,
							 activated_at: Time.zone.now)
end


User.create!(name:	"Site Administrator",
             email: "admin@cityproduce.com",
						 customerid: "ADMIN",
						 admin: true,
						 cuisine: "Inventory",
						 password:              "password",
						 password_confirmation: "password",
						 activated: true,
						 activated_at: Time.zone.now)

User.create!(name:  "Example User",
             email: "example@somewhere.org",
						 customerid: "EXAMPLE",
						 admin: false,
						 cuisine: Cuisine.find_by(id: rand(2..Cuisine.all.size)).name,
             password:              "foobar",
             password_confirmation: "foobar",
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


users = User.order(:created_at).where(admin: false).take(8)
50.times do
  content = Faker::Company.catch_phrase
	oname = Faker::Space.star
  users.each { |user| user.orders.create!(note: content, name: oname, cuisine: user.cuisine) }
end