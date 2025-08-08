# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create sample properties
Property.find_or_create_by!(name: "Royal Suite") do |p|
  p.property_type = "one_bed"
  p.max_guests = 2
  p.description = "Elegant 1-bedroom suite with panoramic city views and luxury amenities."
  p.distance_to_airport_minutes = 25
  p.amenities = ["Wi-Fi", "Smart TV", "Kitchenette", "City View"]
  p.photos = ["/images/interior.jpg", "/images/bedroom.jpg"]
  p.pet_friendly = true
  p.eco_friendly = false

end

Property.find_or_create_by!(name: "Presidential Suite") do |p|
  p.property_type = "two_bed"
  p.max_guests = 4
  p.description = "Spacious 2-bedroom suite with separate living area and premium finishes."
  p.distance_to_airport_minutes = 25
  p.amenities = ["Wi-Fi", "Smart TV", "Full Kitchen", "Balcony", "City View"]
  p.photos = ["/images/interior.jpg", "/images/living.jpg"]
  p.pet_friendly = false
  p.eco_friendly = true

end

Property.find_or_create_by!(name: "Garden Suite") do |p|
  p.property_type = "one_bed"
  p.max_guests = 2
  p.description = "Cozy 1-bedroom suite with private garden access and natural lighting."
  p.distance_to_airport_minutes = 25
  p.amenities = ["Wi-Fi", "Smart TV", "Garden Access", "Parking"]
  p.photos = ["/images/interior.jpg"]
  p.pet_friendly = true
  p.eco_friendly = true

end

puts "Created #{Property.count} properties"
