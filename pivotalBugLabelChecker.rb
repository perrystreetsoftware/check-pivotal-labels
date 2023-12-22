branch_name = ENV['GITHUB_REF'].split('/').last  # GITHUB_REF contains the branch reference
branch_id_match = branch_name.match(/\[#(\d+)\]/)  # Extract branch ID within square brackets
branch_id = branch_id_match[1] if branch_id_match

unless branch_id
  raise "Unable to extract branch ID from the branch name '#{branch_name}'."
end

puts "Branch ID: #{branch_id}"
