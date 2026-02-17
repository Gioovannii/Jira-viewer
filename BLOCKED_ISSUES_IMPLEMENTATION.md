# Blocked Issues Tracking Implementation - Complete

## Overview

Successfully implemented comprehensive blocked issue tracking with time-per-status metrics following Clean Architecture patterns. The feature tracks blocked issues, analyzes flow bottlenecks, and provides detailed status transition timeline.

## Implementation Summary

### Phase 1: Domain Layer (Completed)

#### New Entities Created

1. **StatusTransition.swift** (`Domain/Entities/`)
   - Represents a single status transition in an issue's history
   - Properties: id, fromStatus, toStatus, transitionDate, author

2. **IssueHistory.swift** (`Domain/Entities/`)
   - Tracks complete history of status transitions
   - Business logic methods:
     - `timeInStatus(_:)` - Calculate time spent in specific status
     - `currentStatusDuration(currentStatus:)` - Time in current status
     - `allStatuses()` - Get all unique statuses
     - `statusDurations()` - Time spent in each status

#### Extended Entities

3. **Issue.swift** - Added:
   - Properties: `history`, `isFlagged`
   - Computed properties:
     - `isBlocked` - Detects blocked issues (flagged OR stagnant 3+ days)
     - `daysInCurrentStatus` - Days in current status
     - `slowestStatus` - Status with most time spent
     - `statusDurations` - Time spent in each status

4. **SprintReview.swift** - Added:
   - `BlockedIssuesMetrics` nested type
   - Properties: blockedCount, flaggedCount, stagnantCount, averageBlockedDays, bottleneckStatus

### Phase 2: Data Layer (Completed)

#### New DTOs Created

5. **JiraChangelogDTO.swift** (`Data/DTOs/`)
   - Maps Jira changelog API response
   - Nested types: HistoryItem, ChangeItem, Author

#### Updated DTOs

6. **JiraIssueDTO.swift** - Added:
   - `changelog` property for expanded changelog data
   - `customfield_10021` for flagged field (configurable)
   - `FlaggedFieldDTO` nested type

#### New Mappers Created

7. **IssueHistoryMapper.swift** (`Data/Mappers/`)
   - Maps `JiraChangelogDTO` to `IssueHistory` domain entity
   - Extracts status transitions from changelog
   - Filters for status field changes only

#### Updated Mappers

8. **IssueMapper.swift** - Enhanced:
   - Maps changelog to IssueHistory using new mapper
   - Extracts flagged status from custom field
   - Handles both flagged array and empty cases

#### Updated Repositories

9. **IssueRepository.swift** - Enhanced:
   - Added `expand=changelog` parameter to API requests
   - Includes `customfield_10021` in fields list

10. **JiraEndpoint.swift** - Enhanced:
    - Added `expand` parameter support to `searchIssues` case

11. **ConfigRepository.swift** - Enhanced:
    - Added flagged custom field ID configuration
    - Methods: `getFlaggedCustomFieldId()`, `setFlaggedCustomFieldId(_:)`

12. **UserDefaultsStorage.swift** - Enhanced:
    - Storage for flagged field ID (default: "customfield_10021")

13. **ConfigRepositoryProtocol.swift** - Enhanced:
    - Added protocol methods for flagged field configuration

### Phase 3: Presentation Layer (Completed)

#### Updated ViewModels

14. **IssueListViewModel.swift** - Enhanced:
    - Added `showOnlyBlocked` filter toggle
    - `filteredIssues` computed property for filtering

15. **IssueDetailViewModel.swift** - Enhanced:
    - `statusHistory` - Formatted timeline for display
    - `blockageInfo` - Human-readable blockage information

16. **SettingsViewModel.swift** - Enhanced:
    - Added `flaggedFieldId` property
    - `saveFlaggedFieldId()` method

#### Updated Views

17. **IssueRow.swift** - Enhanced:
    - Blocked indicator badge with warning icon
    - Tooltip shows blocked reason (flagged or stagnant days)

18. **IssueDetailView.swift** - Enhanced:
    - Status History Timeline section with transitions
    - Blockage Warning section (red background)
    - Shows duration, date for each status

19. **IssueListView.swift** - Enhanced:
    - Toggle for "Show only blocked issues"
    - Updates title with filtered count

20. **SprintReviewView.swift** - Enhanced:
    - Blocked Issues Metrics section
    - Shows blocked/flagged/stagnant counts
    - Displays average blocked duration
    - Bottleneck status warning (if detected)

21. **SettingsView.swift** - Enhanced:
    - Advanced section for flagged field ID configuration
    - Help text for Jira instance variations

22. **StatCard.swift** - Enhanced:
    - Added optional `subtitle` parameter

### Phase 4: Use Cases (Completed)

23. **GenerateSprintReviewUseCase.swift** - Enhanced:
    - `calculateBlockedMetrics(issues:)` - Calculates blocked issue metrics
    - `findBottleneckStatus(issues:)` - Identifies workflow bottlenecks
    - Includes blocked metrics in sprint review

## Key Features Implemented

### 1. Blocked Issue Detection
- **Flagged**: Issues marked with Jira impediment flag
- **Stagnant**: Issues in same status for 3+ days
- **Combined**: Visual indicator for both types

### 2. Status Transition Timeline
- Complete history of status changes
- Author and timestamp for each transition
- Duration calculation per status
- Visual timeline in issue detail view

### 3. Workflow Analytics
- Time spent in each status
- Bottleneck detection (status with longest average time)
- Blocked issues metrics in sprint reviews
- Average blocked duration

### 4. Configuration
- Configurable flagged custom field ID
- Default: `customfield_10021`
- Settings UI for adjustment per Jira instance

## Technical Details

### API Integration
- Uses Jira changelog API with `expand=changelog` parameter
- Filters for status field changes
- ISO8601 date parsing for transition timestamps

### Business Rules
- Stagnation threshold: 3 days
- Bottleneck threshold: 2 days (minimum average time)
- Blocked = flagged OR stagnant

### Performance Considerations
- Changelog increases response size
- Efficient status duration calculation
- Cached in Issue entity as computed properties

## Testing Checklist

- [x] Build succeeds without errors
- [ ] Verify changelog fetched in API requests
- [ ] Test blocked badge appears on blocked issues
- [ ] Test filter toggle shows only blocked issues
- [ ] Test timeline displays in issue detail view
- [ ] Test sprint review shows blocked metrics
- [ ] Test flagged field ID configuration in settings
- [ ] Test with issues with no history (new issues)
- [ ] Test with issues with no transitions yet
- [ ] Test bottleneck detection with various datasets

## Files Added to Xcode Project

The following files were programmatically added to the Xcode project:
- Domain/Entities/StatusTransition.swift
- Domain/Entities/IssueHistory.swift
- Data/DTOs/JiraChangelogDTO.swift
- Data/Mappers/IssueHistoryMapper.swift

## Next Steps

1. Run the application and verify blocked issues are detected
2. Test the status timeline with real Jira data
3. Verify the flagged field ID matches your Jira instance
4. Check sprint review blocked metrics calculation
5. Adjust stagnation threshold if needed (currently 3 days)

## Configuration for Your Jira Instance

If blocked issues are not detected correctly, check your Jira custom field for "Flagged":

1. Open Jira Settings > Issues > Custom Fields
2. Find the "Flagged" or "Impediment" field
3. Note the field ID (e.g., "customfield_10021")
4. Update in JiraViewer Settings > Advanced > Flagged Field ID

## Build Status

✅ **BUILD SUCCEEDED** - All files compile without errors
