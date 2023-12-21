branch_name = ENV['GITHUB_REF'].split('/').last  # GITHUB_REF contains the branch reference
story_id_match = branch_name.match(/_(\d+)$/)  # Assuming story ID is at the end of the branch name
story_id = story_id_match[1] if story_id_match

unless story_id
  raise "Unable to extract story ID from the branch name '#{branch_name}'."
end
