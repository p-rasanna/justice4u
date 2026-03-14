# TODO: Client Dashboard Fixes

## High Priority
- [ ] Filter metrics by client: Update activeCases query to count only client's flagged cases (WHERE cname = ? AND flag=1)
- [ ] Filter pendingActions by client: Update pendingActions query to count only client's unassigned cases (WHERE cname = ? AND flag=0)
- [ ] Filter case table by client: Update caseRs query to fetch only client's active cases (WHERE cname = ? AND flag=1)
- [ ] Use PreparedStatement for all queries: Replace Statement with PreparedStatement to prevent SQL injection and improve security

## Medium Priority
- [ ] Add dynamic hearings: Fetch upcoming hearing from DB if hearings table exists, else keep static but note for future
- [ ] Improve error handling: Add try-catch for each query, show user-friendly messages, ensure connections close
- [ ] Enhance mobile UX: Add touch-friendly elements, improve overlay behavior, ensure no zoom on mobile

## Low Priority
- [ ] Add animations/micro-interactions: Implement fade-ins for content, hover effects on table rows, subtle transitions
- [ ] Implement notifications: Replace hardcoded "2" badge with actual unread messages count from DB
- [ ] Ensure full accessibility: Add ARIA labels, ensure contrast, keyboard navigation for interactive elements

## Testing
- [x] Run thorough testing as per QA plan after fixes
