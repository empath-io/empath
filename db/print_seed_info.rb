cadmin = Concierge.first.admins.first
cemp = Concierge.first.employees.first
puts "Concierge org_id: #{cadmin.organization.id}"
puts ""
puts "admin_id:#{cadmin.id}"
puts "admin_login: #{cadmin.login}"
puts "employee_id:#{cemp.id}"
puts "employee_login:#{cemp.login}"
puts ""
vadmin = Vendor.first.admins.first
vemp = Vendor.first.employees.first
puts "Vendor org_id:#{vadmin.organization.id}"
puts ""
puts "admin_id:#{vadmin.id}"
puts "admin_login:#{vadmin.login}"
puts "employee_id: #{vemp.id}"
puts "employee_login: #{vemp.login}"