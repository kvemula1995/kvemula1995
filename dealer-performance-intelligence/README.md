# Dealer Performance & Retention Intelligence

> **A shared way to prioritize dealer accounts:** peer-relative segmentation, a dealer-level churn probability score refreshed daily. Of **2,000+ underperforming dealers** (month-over-month baseline), about **40% returned to target performance** through partnerships run by territory managers and regional sales directors.

| | |
|---|---|
| **Role** | Business problem definition, analytical framing, stakeholder discovery, requirements, hypothesis development, operational adoption |
| **Partners** | Analytics, Sales (territory managers, regional sales directors), Logistics, Customer Experience; hypotheses spanned Arbitration, Pricing, Payments, Onboarding, Customer Service |
| **Stack** | BigQuery · dbt · SQL · Tableau · Salesforce |
| **Status** | Delivered: segmentation, churn EDA and actions, and a dealer-level churn probability score, refreshed daily |

> Exact proprietary grading thresholds, exclusions and production implementation are intentionally omitted. No raw dealer data or production SQL is published.

## Problem

A single performance indicator did not reflect differences in dealer scale, territory demand or growth potential. Teams also lacked a consistent, evidence-based explanation for why dealers went inactive or fell into lower segments.

## What I owned

- The decision framing: which accounts to protect, which to develop, which need intervention
- Segmentation design with field leaders so categories were understandable and actionable
- The churn program structure, cohort definition and hypothesis process across functions
- The review mechanism that turns segments into account prioritization and enablement

## Architecture

![Dealer performance intelligence architecture](./architecture.svg)

## Part 1: Segmentation

Combines two distinct dimensions into a matrix:

- **Relative scale:** a dealer's activity compared with peers in a comparable market
- **Conversion effectiveness:** how efficiently opportunities become completed transactions

Segments are calculated at a consistent dealer-period grain and snapshots are kept, so upgrades, declines and sustained inactivity are visible over time.

**SQL pattern**: monthly date spine → account-month aggregation → rolling lookback windows → approximate-quantile peer thresholds → rule-based classification, with dbt `ref()` dependencies on governed upstream models.

## Part 2: Churn discovery and scoring

| Item | Definition |
|---|---|
| Observation cohort | Dealers with at least one vehicle launched in the preceding 4 weeks |
| Target outcome | No launches in the following 12 weeks |
| Evidence streams | Field-team feedback · direct dealer feedback · quantitative activity analysis |
| Hypotheses | 10+ candidates, prioritized high / medium / low |
| Primary use | Help territory managers and Vehicle Condition Inspectors (VCIs) prioritize and look closely at lister dealers at risk of churn |
| Secondary use | Increase marketing engagement |
| Output | **Dealer-level churn probability score** with the hypothesis-driven factors contributing to each dealer's risk |

| Theme | Candidate signals |
|---|---|
| Arbitration | Buy-side and sell-side share, unwound sales |
| Sales and engagement | Historical sell-through, listing price vs. market benchmark, days since contact, visit history |
| Service and coverage | Representative changes, proximity to field coverage, response to visit requests |
| Vehicle process | Time to sell, time from request to sale, red-light vehicle share |
| Pricing and payments | Competitor price differences, seller payment delays |
| Onboarding and access | Onboarding experience, title-fee experience, revoked selling access |

The hypothesis list is the candidate-feature backlog; not every candidate necessarily became a model input.

## Delivery plan

| Phase | Work | Status |
|---|---|---|
| Segmentation | Matrix framework, review cadence, field adoption | Delivered |
| I. EDA | Identify the primary causes of seller churn | Delivered |
| II. Action planning | Define interventions from Phase I findings (coverage, service recovery, enablement, win-back) | Delivered |
| III. Model build | Prediction model for 12-week inactivity, output as a dealer-level churn probability score with contributing factors, refreshed daily | Delivered |
| Field execution | Territory managers and regional sales directors act on at-risk and underperforming dealers through strategic partnerships | Ongoing |

## Key decisions and trade-offs

| Decision | Why | Trade-off |
|---|---|---|
| Two-dimensional segmentation instead of one score | One score hides scale vs. effectiveness differences | A matrix is slightly harder to explain, so categories were co-designed with field leaders |
| Peer-relative thresholds using approximate quantiles | Fair comparison within a market without one universal cutoff | Needs checks for territory effects and small groups |
| EDA and action planning before model building | Interventions could start before a model existed; avoids a score with no action | Prediction arrived later |
| Show the contributing factors with every score | Field teams act on the reason (coverage, pricing, service), not a bare number | More to explain and maintain |
| Separate observation and outcome windows | Prevents target leakage | Requires strict as-of-date feature availability |
| Triangulate field, dealer and quantitative evidence | Avoids relying on one biased view | More cross-functional coordination |

## Risks and validation approach

| Risk | Mitigation |
|---|---|
| Gradual decline vs. abrupt stop behave differently | Handle both patterns in feature design and validation |
| Future-information leakage | Use only features available at the observation date |
| Signals add nothing beyond simple recency | Test incremental value against recency and history baselines |
| Instability across territories or segments | Check missingness, stability over time and territory effects |
| Correlation read as cause | Distinguish correlation from causation; track whether interventions change behavior |
| Score trusted before it is proven | Validate the 12-week outcome on time-based holdouts before operational use |

## Results (reported)

- Segmentation became a common prioritization mechanism across the organization
- Baseline of **2,000+ underperforming dealers** month over month; about **40% returned to target performance** through strategic partnerships executed by territory managers and regional sales directors
- Dealer-level churn probability score with contributing factors, supporting earlier intervention
- Reactivation initiatives associated with improved activity among previously inactive dealers

Further quantitative and commercial details are confidential.

## Signals this demonstrates

Analytics strategy · customer segmentation · churn modeling · hypothesis-led problem solving · technical depth in SQL/dbt · phased delivery · stakeholder alignment · operational adoption

## Confidentiality

No raw dealer data, account identifiers, production SQL, internal thresholds, exclusion rules or proprietary model features are published.
