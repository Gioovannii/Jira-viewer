#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'JiraViewer.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Find Infrastructure/Storage group
main_group = project.main_group
infrastructure_group = main_group.children.find { |g| g.display_name == 'Infrastructure' }
if infrastructure_group
  storage_group = infrastructure_group.children.find { |g| g.display_name == 'Storage' }

  if storage_group
    file_path = 'Infrastructure/Storage/SimpleSecureStorage.swift'

    # Check if already exists
    existing = storage_group.children.find { |c| c.display_name == 'SimpleSecureStorage.swift' }

    if existing
      puts "File already in project: #{file_path}"
    else
      # Add file
      file_ref = storage_group.new_reference(file_path)
      target.source_build_phase.add_file_reference(file_ref)
      puts "Added: #{file_path}"
    end
  else
    puts "Storage group not found"
  end
else
  puts "Infrastructure group not found"
end

project.save
puts "Project updated!"
