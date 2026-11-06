# Methodology — Dealer Performance & Retention Intelligence

## 1. Define the business decision

Clarify what field teams need to decide: which accounts to protect, which to develop, and which require a targeted intervention. Avoid building a score without a corresponding action.

## 2. Grade on two independent dimensions

- **Sales volume (relative):** rank dealers within their own territory on recent sales and split them into tertiles, so territories with different demand levels are compared fairly.
- **Sell-through rate (absolute):** group dealers using fixed bands applied identically across territories and time, so conversion is judged the same everywhere.

Combine the two in a matrix that yields three grades: **A** (top performers), **B** (stable, room to grow) and **E** (conversion inefficiency needing immediate intervention). The public methodology excludes exact thresholds, the lookback window and the full grade rules.

## 3. Run it as a monthly mechanism

Recalculate monthly at a consistent dealer-period grain, keep snapshots to see upgrades, declines and sustained inactivity, and agree with Sales, Analytics and Ops that the grade is the single source of truth for prioritization.

## 4. Define early-risk signals

Create an explainable early-disengagement indicator using a recent-activity window followed by a sustained inactivity window. Validate the window lengths against historical behavior before operational use.

## 5. Run four churn-discovery streams in parallel

- **Field perspective:** send a monthly churned-dealer list to territory sales leaders to record likely reasons.
- **Dealer feedback:** have a call-center team ask each long-inactive dealer why they stopped.
- **Data-driven:** define early churn (recent launch, then a sustained quiet period), convene Sales, Analytics, Logistics and Customer Experience to list assumptions, and test 10+ hypotheses. Distinguish correlation from causation.
- **Generative AI:** analyze territory manager visit logs to surface and validate trends from the field's own notes.

Triangulate the four so no single biased view drives the answer.

## 6. Translate findings into interventions

Match the top churn reasons (competitor loss, thin coverage, poor buy or sell experience) to actions such as guaranteed-sale programs, fee reductions, transportation credits, coverage improvements and win-back outreach. Track assignment, execution, and outcome.

## 7. Measure impact

Track grade migration, reactivation, recovered volume against the baseline of volume lost from churned dealers, retention, and fee contribution. Use a defined baseline and comparison approach where feasible; avoid attributing all subsequent activity to a single intervention.


## Churn hypothesis and feature-discovery process

### Prediction framing

Define the observation cohort as dealers with at least one launch in the preceding four weeks. Define the forward-looking outcome as no launches during the following 12 weeks. Keep observation and outcome windows separate to prevent target leakage.

### EDA and hypothesis evaluation

Organize candidate hypotheses into feature families:
- **Arbitration and transaction quality:** buy-side arbitration incidence, unwind/return patterns, and sell-side arbitration.
- **Sales and engagement:** historical sell-through, relative listing price, deal-making calls, days since contact, and buyer/seller-side engagement.
- **Field coverage:** visit history of Vehicle Condition Inspectors (VCIs), territory manager (TM) visit and sales-meeting history, unique VCI coverage, proximity to a VCI, and response to visit requests.
- **Service experience:** changes in customer service or inside representatives.
- **Vehicle processing:** time to sell, time from condition-report (CR) creation to sale, red-light vehicle mix, and time from field-service request to sale.
- **Commercial and account experience:** competitor pricing, seller payment delays, onboarding, title-fee experience, and selling-access changes.

### Validation considerations (design principles for the churn work)

- Compare gradual activity decline with abrupt inactivity; the planning notes identify both patterns.
- Evaluate feature availability as of the observation date to avoid future-information leakage.
- Check missingness, stability over time, territory effects, and differences between dealer segments.
- Test whether candidate signals add predictive value beyond simple recency and historical activity.
- Validate the 12-week outcome over time-based holdouts before operationalizing risk scores.
- Review recommendations with field teams and track whether interventions change subsequent dealer activity.

### Phased delivery

The plan separated EDA, action planning and model build. The model build was delivered as a dealer-level churn probability score that also shows which hypothesis-driven factors contribute to each dealer's risk, so field teams can act on the reason, not just the score.


## Engineering approach

The grading output is built as a sequence of staged, reusable dbt models on BigQuery rather than one monolithic query, so downstream reporting consumes a standardized result.

### Confidentiality boundary

Internal model references, exclusion logic, thresholds, date boundaries and grading rules are intentionally not reproduced.
