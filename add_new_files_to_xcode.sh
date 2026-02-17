#!/bin/bash

# Add new files to Xcode project
FILES=(
  "Domain/Entities/StatusTransition.swift"
  "Domain/Entities/IssueHistory.swift"
  "Data/DTOs/JiraChangelogDTO.swift"
  "Data/Mappers/IssueHistoryMapper.swift"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "File exists: $file"
  else
    echo "File missing: $file"
  fi
done
