# Week 16 — Power BI Dashboard Final Release

## Overview

Week 16 completed the Power BI implementation layer of the NHS Operational Data Platform.

The dashboard converts the validated PostgreSQL analytical layer and Week 15 semantic model into a management-facing operational intelligence product.

The project uses synthetic operational data only.

---

## Dashboard Pages

The final dashboard contains:

1. Executive Overview
2. Beds & Patient Flow
3. A&E & Ambulance
4. Workforce Pressure
5. OPEL & Governance
6. Trust-Day Investigation
7. Data Quality & Lineage
8. KPI Definitions & Interpretation

---

## Executive Overview

The Executive Overview provides senior users with headline operational indicators including:

- Weighted General-Bed Occupancy
- Total A&E Attendances
- Weighted A&E Four-Hour Breach Rate
- Weighted Workforce Absence
- OPEL 3–4 Trust-Days
- Human Override Count

It also provides Trust and Date filtering and high-level operational-pressure and OPEL analysis.

---

## Beds & Patient Flow

The page provides:

- Weighted General-Bed Occupancy
- Maximum General-Bed Occupancy
- Weighted Critical-Care Occupancy
- Discharge-Ready Patient-Days
- occupancy trends
- general versus critical-care comparison
- admissions versus discharges
- net patient flow
- discharge-ready patient-day analysis

Validated full-period flow values:

- Admissions = 16,425
- Discharges = 15,654
- Net Admissions = 771

---

## A&E & Ambulance

The page provides:

- Total A&E Attendances
- Total Four-Hour Breaches
- Weighted A&E Four-Hour Breach Rate
- Total Ambulance Arrivals
- Total Ambulance Handover Delays
- A&E trends
- Trust-level breach-rate comparison
- ambulance activity analysis

Validated A&E values:

- Attendances = 25,800
- Four-Hour Breaches = 5,113
- Weighted Four-Hour Breach Rate ≈ 19.8%

The ambulance delay-rate metric remains provisional because the exact business definition of the source field requires confirmation before production interpretation.

No interpretation in minutes is used.

---

## Workforce Pressure

The page provides:

- Weighted Workforce Absence
- Average Establishment FTE
- Average Substantive FTE
- Average Daily Agency FTE
- Average Daily Bank FTE
- Total Unfilled Shifts
- workforce-absence trend
- Trust-level absence comparison
- agency versus bank analysis
- unfilled-shift analysis

Weighted absence is calculated from absence FTE and establishment FTE rather than a simple average of daily percentage fields.

---

## OPEL & Governance

The page provides:

- OPEL 3–4 Trust-Days
- OPEL 4 Trust-Days
- High-Pressure Trust-Days
- Human Override Count
- Human Override Rate
- Recommendation Agreement Percentage
- Approved OPEL distribution
- Trust-level elevated OPEL analysis
- human-override analysis

Validated full-period results:

- OPEL 3–4 Trust-Days = 39
- OPEL 4 Trust-Days = 7
- High-Pressure Trust-Days = 39
- Human Overrides = 4
- Human Override Rate ≈ 4.4%
- Recommendation Agreement ≈ 95.6%

Recommended and Approved OPEL remain separate to preserve human oversight and traceability.

---

## Trust-Day Investigation

The investigation page provides operational drill-down by:

- Trust
- reporting date
- Approved OPEL
- Recommended OPEL
- Previous Approved OPEL
- Human Override
- Prediction Confidence
- Operational Pressure Status
- Weather Warning Context
- available governance metadata

The page also provides detailed analysis of:

- recommendation-versus-approval outcomes
- human override cases
- pressure status
- weather-warning context

Weather information is contextual only and is not presented as causal evidence.

---

## Data Quality & Lineage

The page provides:

- Fact Trust-Day Rows
- Duplicate Trust-Date Count
- Reporting Completeness
- Net Admissions Reconciliation Variance
- Override Reconciliation Variance
- reporting coverage
- KPI reconciliation
- source lineage
- data-quality status
- semantic-model governance

Validated controls:

- Fact Rows = 90
- Duplicate Trust-Date Rows = 0
- Reporting Completeness = 100%
- Net Admissions Variance = 0
- Override Reconciliation Variance = 0

---

## KPI Definitions & Interpretation

The final reference page documents:

- KPI definitions
- weighting logic
- Trust-Day terminology
- patient-day interpretation
- OPEL governance
- project-defined pressure classifications
- ambulance provisional status
- synthetic-data limitations
- production-readiness caveats

---

## Semantic Model

The validated architecture is:

PostgreSQL
→ Analytical View
→ Power Query
→ Star Schema
→ Governed DAX Measures
→ Power BI Dashboard

Loaded Power BI model tables:

- FactTrustDailyOperations
- DimDate
- DimTrust
- DimOPEL
- DimPressureStatus
- DimWeatherWarning
- _Measures

Dimension-to-fact relationships are one-to-many, active and single-direction.

The _Measures table is deliberately disconnected.

Staging and QA queries remain load-disabled.

---

## Human-in-the-Loop Governance

The project deliberately separates:

- Recommended OPEL
- Approved OPEL

Recommended OPEL represents decision-support output.

Approved OPEL represents the human-reviewed outcome within the project workflow.

A Human Override occurs when:

recommended_opel_level <> approved_opel_level

Validated results:

- Human Overrides = 4
- Recommendation/Approval Mismatches = 4
- Override Reconciliation Variance = 0

This supports:

- human accountability
- auditability
- traceability
- model-versus-human comparison

---

## Final Dashboard UAT

Final dashboard UAT covered:

- page navigation
- Trust filtering
- Date filtering
- combined filtering
- cross-visual interactions
- KPI reconciliation
- tooltip behaviour
- terminology
- accessibility
- number formatting
- visual consistency

Known filter-context controls include:

- Full dataset = 90 Trust-Days
- One Trust = 30 Trust-Days
- Ten days across all Trusts = 30 Trust-Days
- One Trust across ten days = 10 Trust-Days

Final Dashboard UAT:

PASS

---

## Limitations

The dashboard:

- uses synthetic data only
- contains no patient or staff identifiers
- is not intended for clinical use
- is not intended for live operational decision-making
- does not establish causal relationships
- uses project-defined pressure classifications
- retains a provisional ambulance metric pending source-definition confirmation
- requires source, governance and deployment revalidation before production use

---

## Week 16 Outcome

Week 16 delivered a complete management-facing Power BI layer on top of the validated PostgreSQL and semantic-model foundation.

The finished product demonstrates:

- operational analytics
- dimensional modelling
- DAX
- data-quality assurance
- lineage
- reconciliation
- human-in-the-loop governance
- investigation capability
- management reporting
- responsible interpretation of ambiguous data
