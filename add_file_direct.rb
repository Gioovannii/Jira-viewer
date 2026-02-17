#!/usr/bin/env ruby
require 'xcodeproj'

project = Xcodeproj::Project.open('JiraViewer.xcodeproj')
target = project.targets.first

file_path = 'Infrastructure/Storage/SimpleSecureStorage.swift'

# Add to main group
file_ref = project.main_group.new_reference(file_path)
target.source_build_phase.add_file_reference(file_ref)

project.save
puts "Added #{file_path}"
