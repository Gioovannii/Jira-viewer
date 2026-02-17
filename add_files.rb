#!/usr/bin/env ruby

require 'xcodeproj'

# Open the project
project_path = 'JiraViewer.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Define the files to add with their groups
files_to_add = [
  { path: 'Domain/Entities/StatusTransition.swift', group_path: 'Domain/Entities' },
  { path: 'Domain/Entities/IssueHistory.swift', group_path: 'Domain/Entities' },
  { path: 'Data/DTOs/JiraChangelogDTO.swift', group_path: 'Data/DTOs' },
  { path: 'Data/Mappers/IssueHistoryMapper.swift', group_path: 'Data/Mappers' }
]

# Helper method to find or create group
def find_or_create_group(project, path_components)
  group = project.main_group
  path_components.each do |component|
    existing = group.children.find { |child| child.display_name == component && child.is_a?(Xcodeproj::Project::Object::PBXGroup) }
    if existing
      group = existing
    else
      group = group.new_group(component)
    end
  end
  group
end

# Add each file
files_to_add.each do |file_info|
  file_path = file_info[:path]
  group_path = file_info[:group_path].split('/')

  # Check if file exists
  unless File.exist?(file_path)
    puts "File not found: #{file_path}"
    next
  end

  # Find or create the group
  group = find_or_create_group(project, group_path)

  # Check if file is already in the project
  existing_file = group.children.find { |child| child.display_name == File.basename(file_path) }
  if existing_file
    puts "File already in project: #{file_path}"
    next
  end

  # Add the file reference
  file_ref = group.new_reference(file_path)

  # Add to build phase
  target.source_build_phase.add_file_reference(file_ref)

  puts "Added: #{file_path}"
end

# Save the project
project.save

puts "\nProject updated successfully!"
puts "Please close and reopen Xcode to see the changes."
