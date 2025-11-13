# Document List Status Filter

## Overview
Added a multi-select status filter to the document list that allows filtering documents by their processing status.

## Features

### Multi-Select Filter
- Located in the header, adjacent to the "Load" time interval dropdown
- Styled as a ButtonDropdown to match the "Load" filter
- Allows selecting multiple status values simultaneously
- Shows checkmarks next to selected statuses
- Displays count of selected filters (e.g., "Status: 3 selected") or "Status: All" when none selected

### Available Status Options
These match the backend `Status` enum from `idp_common.models`:

- **QUEUED** - Initial state when document is added to queue
- **RUNNING** - Step function workflow has started
- **OCR** - OCR processing in progress
- **CLASSIFYING** - Document classification in progress
- **EXTRACTING** - Information extraction in progress
- **ASSESSING** - Document assessment in progress
- **POSTPROCESSING** - Post-processing stage
- **HITL_IN_PROGRESS** - Human-in-the-loop review in progress
- **SUMMARIZING** - Document summarization in progress
- **EVALUATING** - Document evaluation in progress
- **COMPLETED** - All processing completed successfully
- **FAILED** - Processing failed at some stage

## Usage

1. **Filter by Single Status**: Click the "Status" dropdown and select one status (checkmark appears)
2. **Filter by Multiple Statuses**: Click additional statuses to add them to the filter
3. **Remove a Filter**: Click a selected status again to deselect it (checkmark disappears)
4. **Clear All Filters**: Deselect all statuses to show all documents

## Implementation Details

### Files Modified
- `src/ui/src/components/document-list/DocumentList.jsx`
  - Added `statusFilter` state
  - Added `filteredDocumentList` state
  - Added filtering logic in useEffect
  - Passes filter props to header component

- `src/ui/src/components/document-list/documents-table-config.jsx`
  - Added `PROCESSING_STATUS_OPTIONS` constant
  - Added ButtonDropdown component for status filter (matches Load filter styling)
  - Added `onStatusFilterClick` handler for toggle behavior
  - Added `statusFilter` and `onStatusFilterChange` props
  - Shows checkmarks for selected statuses

### Filtering Logic
```javascript
// When no filter is selected, show all documents
if (statusFilter.length === 0) {
  setFilteredDocumentList(documentList);
} else {
  // Filter to show only documents matching selected statuses
  const selectedStatuses = statusFilter.map((option) => option.value);
  const filtered = documentList.filter((doc) => 
    selectedStatuses.includes(doc.objectStatus)
  );
  setFilteredDocumentList(filtered);
}
```

## UI Layout

```
[Load: 1 day ▼] [Filter by status ▼] [↻] [↓] [Reprocess →] [Remove]
```

The status filter is positioned between the time interval dropdown and the refresh button for easy access.

## Notes
- Filter state is maintained in component state (not persisted to localStorage)
- Filter is disabled when documents are loading
- Export to Excel respects the current filter
- Filter works in combination with the text search filter
