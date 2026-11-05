# Methodology — Dealer Performance & Retention Intelligence

## 1. Define the business decision

Clarify what field teams need to decide: which accounts to protect, which to develop, and which require a targeted intervention. Avoid building a score without a corresponding action.

## 2. Build a balanced performance view

Use two conceptually distinct dimensions:
- **Relative scale:** compare dealer activity with peers in a comparable market.
- **Conversion effectiveness:** assess how efficiently available inventory or opportunities translate into completed transactions.

The public methodology intentionally excludes the employer's exact thresholds, peer-group implementation, and proprietary grade mapping.

## 3. Create stable time-based segments

Calculate performance at a consistent dealer-period grain. Retain historical snapshots to identify upgrades, declines, and sustained inactivity rather than relying only on the latest period.

## 4. Define early-risk signals

Create an explainable early-disengagement indicator using a recent-activity window followed by a sustained inactivity window. Validate the window lengths against historical behavior before operational use.

## 5. Test churn hypotheses

Triangulate:
- Field observations and structured reason codes
- Direct customer feedback
- Quantitative transaction, inventory, and engagement patterns

Form hypotheses with cross-functional stakeholders, test whether the evidence supports them, and distinguish correlation from causation.

## 6. Translate findings into interventions

Match likely barriers to relevant actions, such as coverage improvements, service recovery, commercial enablement, or win-back outreach. Track assignment, execution, and outcome.

## 7. Measure impact

Track segment migration, reactivation, incremental units, retention, and fee contribution. Use a defined baseline and comparison approach where feasible; avoid attributing all subsequent activity to a single intervention.


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


## SQL patterns demonstrated

The reviewed dealer-grading SQL is structured as a sequence of transformations rather than one monolithic query. At a high level, the query follows this pattern:

1. **Build a monthly date spine:** Generate month-level evaluation dates and associated historical windows.
2. **Prepare transaction-level activity:** Join auction activity to relevant dealer and operational context, then aggregate listing and sold outcomes at a dealer and time-period level.
3. **Create historical performance measures:** Aggregate activity over defined lookback periods to distinguish recent performance from longer-term trends.
4. **Establish peer-relative thresholds:** Use approximate quantiles within geographic or operating groups to create comparable performance bands.
5. **Apply classification logic:** Combine sales-volume and sell-through indicators into a consistent dealer-segmentation output.
6. **Publish a reusable analytical model:** Organize the transformations through dbt model references so downstream reporting can consume a standardized result.

### SQL techniques represented

| Technique | How it is used conceptually |
|---|---|
| Common table expressions (CTEs) | Break a complex transformation into readable, testable stages |
| `GENERATE_DATE_ARRAY` | Build a regular monthly evaluation calendar |
| Date truncation and date arithmetic | Align activity to monthly periods and construct historical windows |
| `LEFT JOIN` | Enrich transaction activity with dealer and operational dimensions while retaining the core activity set |
| `COUNT(DISTINCT ...)` with conditional logic | Calculate unique listing and sold-transaction measures |
| `SUM` and grouped aggregation | Roll transaction activity up to dealer-period and geography levels |
| `APPROX_QUANTILES` | Create peer-relative performance thresholds without hard-coding a single universal cutoff |
| `CASE` expressions | Convert analytical measures into interpretable categories |
| dbt `ref()` | Express dependencies on upstream modeled datasets |

This is a high-level technical description of the reviewed SQL file, not a claim that every project in this repository used every listed technique.

### Confidentiality boundary

The original script contains internal model references, exclusion logic, account-specific conditions, date boundaries, and grading rules. Those implementation details are intentionally not reproduced. The public project documents the reusable SQL engineering patterns and analytical approach instead.
