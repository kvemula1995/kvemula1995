# Methodology — AI-Enabled Analytics Delivery

## 1. Start from the decision latency

Measure how long leaders wait from question to answer and where the time goes: understanding the ask, pulling data, and the layers between them. The target is removing the layers, not speeding each one up.

## 2. Inventory and prioritize

List every dashboard and underlying table in scope. Rank by who depends on it and by the deadline. Put executive-priority reporting first so the earliest delivery carries the most visible value.

## 3. Build one governed data layer

Use dbt to express denormalized tables as version-controlled SQL with YAML definitions. Define each core metric once, in that layer, so dashboards and AI chat read the same definition.

## 4. Design AI topics around outcomes

Start from the questions stakeholders actually ask. Group data into topics by outcome, and apply logic rules so each department only reaches what it should.

## 5. Control quality before release

- Pull requests and code review for every data-layer change
- Automated discrepancy detection to compare migrated output with existing reporting and surface mismatches early

## 6. Deliver in waves

Release the priority tables first, validate with the leaders who depend on them, then migrate the rest of the scope within the quarter.

## 7. Measure the outcome

Track time from question to answer, the number of ad hoc analyst requests, and confidence in the numbers. Report what changed and be explicit about which results are reported versus measured.
