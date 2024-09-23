require 'csv'

Rails.application.eager_load!

course = ARGV[0]
if course.nil? || course == "" 
  puts "Need courseid, e.g., COSC101S21"
  exit
end

date = ARGV[1]
if date.nil? || date == ""
  puts "Need date, e.g., 0902"
  exit
end
d = date[-2..-1].to_i
m = date[0...-2].to_i

student = ARGV[2]
if student.nil? || date == ""
  puts "Need user email, e.g., jsommers"
  exit
end

remove = false
if student =~ /-$/ 
  student = student.gsub /-$/, ''
  remove = true
end

student = User.where(email: "#{student}@colgate.edu").first

course = Course.find_by(:name => course)
puts "Course: #{course.name}"
attendance = course.attendance_for(m, d)
puts "Attendance found: #{attendance.created_at}"

if !remove
  attendance.users << student
  puts "Student #{student.email} added to attendance for #{course.name} on #{date}"
else
  attendance.users.delete(student)
  puts "Removed #{student.email} from attendance for #{course.name} on #{date}"
end
