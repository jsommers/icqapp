require 'csv'

Rails.application.eager_load!

course = ARGV[0]
if course.nil? || course == "" 
  puts "Need courseid, e.g., COSC101S21"
  exit
end

seedfile = ARGV[1]
if seedfile.nil? || !File.exist?(seedfile)
  puts "Seed file #{seedfile} doesn't exist"
  exit
end

course = Course.find_by(:name => course)
puts course

all_emails = []

CSV.foreach(seedfile) do |row|
  next if row[0] =~ /Student/
  if row.join =~ /\*\*registered\*\*/i
    email = row[-2]
    all_emails << email
    # puts "#{email}"
  end
end

all_emails.each do |email|
  std = User.find_by(:email => email)
  if std.nil?
    puts "adding #{email}"
    std = User.create(:email => email)
    course.students << std
  elsif course.students.where(:email => email).count == 0
    course.students << std
  end
end

to_remove = course.students.pluck(:email) - all_emails
to_remove.each do |e|
  puts "removing #{e}"
  std = User.find_by(:email => e)
  std.destroy
end

puts "#{course.students.count} registered for #{course.name}"
