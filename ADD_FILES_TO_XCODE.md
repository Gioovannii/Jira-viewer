# Files to Add to Xcode Project

The blocked issues tracking feature has been implemented. The following new files need to be added to the Xcode project:

## Steps to Add Files

1. Open `JiraViewer.xcodeproj` in Xcode
2. For each file listed below, right-click on the appropriate folder and select "Add Files to JiraViewer..."
3. Select the file and make sure "Copy items if needed" is UNCHECKED
4. Make sure "JiraViewer" target is checked
5. Click "Add"

## New Files to Add

### Domain/Entities/
- `StatusTransition.swift` - Represents a status transition in issue history
- `IssueHistory.swift` - Tracks complete history of status transitions

### Data/DTOs/
- `JiraChangelogDTO.swift` - DTO for Jira changelog API response

### Data/Mappers/
- `IssueHistoryMapper.swift` - Maps JiraChangelogDTO to IssueHistory domain entity

## Alternative: Use Finder

1. Open Xcode with JiraViewer.xcodeproj
2. In Finder, navigate to the project folder
3. Drag each file from Finder into the appropriate group in Xcode's Project Navigator
4. In the dialog that appears:
   - Uncheck "Copy items if needed"
   - Check "JiraViewer" target
   - Click "Finish"

## After Adding Files

Run the build command to verify:
```bash
xcodebuild -project JiraViewer.xcodeproj -scheme JiraViewer -configuration Debug build
```

## Files Already Modified (Already in Project)

The following existing files have been updated and should compile correctly once the new files are added:

- Domain/Entities/Issue.swift
- Domain/Entities/SprintReview.swift
- Data/DTOs/JiraIssueDTO.swift
- Data/Mappers/IssueMapper.swift
- Data/Repositories/IssueRepository.swift
- Data/DataSources/Remote/JiraEndpoint.swift
- Data/DataSources/Local/UserDefaultsStorage.swift
- Data/Repositories/ConfigRepository.swift
- Domain/RepositoryProtocols/ConfigRepositoryProtocol.swift
- Domain/UseCases/Sprint/GenerateSprintReviewUseCase.swift
- Presentation/ViewModels/IssueListViewModel.swift
- Presentation/ViewModels/IssueDetailViewModel.swift
- Presentation/ViewModels/SettingsViewModel.swift
- Presentation/Views/Issue/IssueRow.swift
- Presentation/Views/Issue/IssueDetailView.swift
- Presentation/Views/Issue/IssueListView.swift
- Presentation/Views/Sprint/SprintReviewView.swift
- Presentation/Views/Settings/SettingsView.swift
- Presentation/Views/Components/StatCard.swift
