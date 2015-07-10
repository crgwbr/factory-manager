require_relative 'models.rb'

tag_us = Tag.create(:name => 'United States')
tag_cars = Tag.create(:name => 'Cars')
tag_bikes = Tag.create(:name => 'Bikes')
tag_shoes = Tag.create(:name => 'Shoes')

factory = Factory.new(
  :name => 'Nike',
  :email => 'sales@nike.com',
  :address => "1600 Pennsylvania Ave, Washington, DC 20500"
)
factory.tags << tag_us
factory.tags << tag_shoes
factory.save()

factory = Factory.new(
  :name => 'Bikes!',
  :email => 'sales@bike.com',
  :address => "11 Wall Street New York, NY"
)
factory.tags << tag_us
factory.tags << tag_bikes
factory.save()

factory = Factory.new(
  :name => 'Honda',
  :email => 'sales@honda.com',
  :address => "25 Jay St, Brooklyn, NY 11201"
)
factory.tags << tag_us
factory.tags << tag_cars
factory.save()
