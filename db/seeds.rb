# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Rails.application.eager_load!
User.destroy_all
Course.destroy_all

me = User.create!(:email => 'jsommers@colgate.edu', :admin => true)

c415 = Course.create!(:name => 'COSC415F24', :daytime => 'MWF 9:20-10:10')
c415.instructors << me

c255 = Course.create!(:name => 'COSC255F24', :daytime => 'MWF 10:20-11:10')
c255.instructors << me
