require 'tracker_api'

branch_name = ENV['GITHUB_HEAD_REF'] 
branch_id_match = branch_name.match(/_(\d+)$/)  # Extract numeric ID at the end of the branch name
branch_id = branch_id_match[1] if branch_id_match

unless branch_id
  raise "Unable to extract ID from the branch name '#{branch_name}'."
end

# Set your Pivotal Tracker API token and project ID
token = ENV['PIVOTAL_TOKEN']
client = TrackerApi::Client.new(token: token)

# Create a new Pivotal Tracker project client
story = client.story(branch_id)

# Function to clean up label names
def clean_label_name(label_name)
  label_name.to_s.downcase.gsub(/[^a-z0-9]/, '')
end

impact_labels = ["prod", "beta", "develop"]
source_labels = ["feature", "legacy", "refactor"]

def label_matches?(label_name, valid_labels)
  puts clean_label_name(label_name)
  clean_label_name(label_name) =~ Regexp.union(valid_labels.map { |label| Regexp.new(clean_label_name(label)) })
end

if story.story_type == 'bug'
  hasImpactLabel = false
  hasSourceLabel = false
  
  
  unless story.labels.none? { |label| label_matches?(label.name, impact_labels) } 
    hasImpactLabel = true
  end 
  unless story.labels.none? { |label| label_matches?(label.name, source_labels) } 
    hasSourceLabel = true
  end 
  
  unless hasSourceLabel && hasImpactLabel
    raise "Story '#{story.name}' does not contain expected impact/source labels."
  end
end
