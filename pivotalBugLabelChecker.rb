#!/usr/bin/env ruby
# frozen_strings_literal: true
require 'tracker_api'

class CheckBugLabels

  PIVOTAL_TOKEN = ENV['PIVOTAL_TOKEN']
  BRANCH_NAME = ENV['GITHUB_HEAD_REF']
  
  BRANCH_ID = BRANCH_NAME.match(/_(\d+)$/)  # Extract numeric ID at the end of the branch name
  PIVOTAL_STORY_ID = BRANCH_ID ? BRANCH_ID[1] : exit(0)
  IMPACT_LABELS = ["prod", "beta", "develop"]
  SOURCE_LABELS = ["feature", "legacy", "refactor"]
  REGRESSION_LABELS = ["regression"]

  def execute
    if PIVOTAL_STORY_ID
      story = client.story(PIVOTAL_STORY_ID)
    
      if story.story_type == 'bug'
        check_impact_labels(story)
        check_source_labels(story)
        check_regression_labels(story)
      end
    end
    
    exit
  end

  def check_impact_labels(story)
    if story.labels.none? { |label| label_matches?(label.name, IMPACT_LABELS) }
      raise "Story ##{story.id} does not contain the impact label"
    end
  end

  def check_source_labels(story)
    if story.labels.none? { |label| label_matches?(label.name, SOURCE_LABELS) }
      raise "Story ##{story.id} does not contain the source label"
    end 
  end

  def check_regression_labels(story)
    unless story.labels.none? { |label| label_matches?(label.name, REGRESSION_LABELS) }
      blocker = story.blockers&.first&.description
      blocker_story_id = blocker ? blocker[/\d+$/]&.to_i : nil

      unless blocker_story_id
        raise "Story ##{story.id} is a regression but the story id that caused the regression is missing from the blockers"
      end

      begin
        client.story(blocker_story_id)
      rescue => error
        raise "Story ##{story.id} is a regression but the story id in the blockers is not a valid story"
      end
    end
  end

  def clean_label_name(label_name)
    label_name.to_s.downcase.gsub(/[^a-z0-9]/, '')
  end
  
  def label_matches?(label_name, valid_labels)
    clean_label_name(label_name) =~ Regexp.union(valid_labels.map { |label| Regexp.new(clean_label_name(label)) })
  end

  def client
    @client ||= TrackerApi::Client.new(token: PIVOTAL_TOKEN)
  end

end

CheckBugLabels.new.execute if __FILE__ == $PROGRAM_NAME
