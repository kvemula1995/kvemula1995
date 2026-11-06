# Methodology — Workforce Planning & Hiring Automation

## 1. Diagnose the process

Map the current requisition journey, identify handoffs, measure elapsed time, and document where requests wait for action. Separate process delays from actual review effort.

## 2. Define decision inputs

Create a consistent validation checklist covering:
- Territory workload and expected demand
- Existing inspector capacity and utilization
- Geographic coverage and proximity alternatives
- Local dealer activity and service requirements
- Hiring location rationale and operational constraints

The published checklist is intentionally generic and does not reproduce internal approval logic.

## 3. Design the target workflow

Define each stage, its accountable role, required inputs, decision outcomes, and next handoff. Establish clear paths for approval, rejection, clarification, and recruitment completion.

## 4. Automate communication and instrumentation

Trigger notifications when a request is submitted or a material workflow decision changes. Capture stage-entry and stage-completion timestamps so that time spent at each handoff can be analyzed.

## 5. Measure SLA performance

Recommended measures:
- End-to-end turnaround (request to approval)
- Time in each approval stage
- Percentage completed within target SLA
- Requests awaiting action by stage
- Rework and rejection rates
- Notification failures and overdue requests

## 6. Govern and improve

Review aging requests with process owners, investigate recurring bottlenecks, and refine training and decision guidance. Maintain clear ownership for workflow configuration and metric definitions.

## Reported result

Request-to-approval turnaround (before recruitment starts) was reduced from 2 weeks to 1–2 business days, the SLA target, and request-to-hire from 2–3 months to 15 business days. Recruitment progress is tracked separately with its own timestamps. This is a reported program outcome, not a universal benchmark.


## Swimlane-specific operating design

1. **Field intake:** Capture requester, territory, position, reason, and preferred location; distinguish backfill from new addition.
2. **HR review:** Review the submission and update the central tracker.
3. **Analyst acknowledgement:** Make ownership visible and begin the assessment.
4. **Analyst evaluation:** Consider strategic hiring location, territory resource utilization, and cross-territory coverage availability.
5. **Approval:** Present the analyst opinion (No objection / Objection) and supporting findings to the final approver for an Approved / Not approved decision.
6. **Recruitment handoff:** Route approved requests to recruitment and track progress through completion.

This structure supports measurement of both total elapsed time and time spent at each organizational handoff.


## Apps Script automation patterns

The implementation uses event-driven Google Apps Script functions:

- **Form-submit event:** Extracts submitted form values, composes request summaries, and sends notification emails to designated stakeholders.
- **Edit event:** Checks the edited sheet, row, and column; maps workflow status fields to timestamp fields; and records the first transition time for SLA measurement.
- **Stage-based notifications:** Sends decision-specific emails when HR approval, analyst recommendation, or final approver status changes.
- **SLA instrumentation:** Captures timestamps for key workflow transitions so turnaround time can be measured by stage rather than relying on manual status updates.

These descriptions reflect the shared Apps Script logic at a functional level. Email addresses, spreadsheet identifiers, internal sheet names, and production-specific column mappings are excluded.
