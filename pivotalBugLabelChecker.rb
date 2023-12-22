branch_name = ENV['GITHUB_HEAD_REF']  # GITHUB_REF contains the branch reference .split('/').last
branch_id_match = branch_name.match(/_(\d+)$/)  # Extract numeric ID at the end of the branch name
branch_id = branch_id_match[1] if branch_id_match

unless branch_id
  raise "Unable to extract ID from the branch name '#{branch_name}'."
end

puts "ID: #{branch_id}"
