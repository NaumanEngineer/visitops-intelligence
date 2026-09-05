\# VisitOps Intelligence - AI Architecture Blueprint



Strategic integration of SQL analytics with Claude API reasoning layer for AI-augmented domiciliary care decision support.



\---



\## Architecture Philosophy



\*\*Separation of Concerns:\*\*

\- \*\*Data Layer (SQL):\*\* Aggregation, validation, anomaly detection, scoring

\- \*\*Reasoning Layer (Claude):\*\* Interpretation, explanation, recommendation, compliance checking

\- \*\*Presentation Layer (Power BI):\*\* Visualization, narrative insights, stakeholder reporting



This design ensures:

\- Explainability: Every recommendation has a traceable reasoning path

\- Governance: Data and reasoning separated for compliance auditing

\- Scalability: SQL handles scale, Claude handles complexity

\- Transparency: Non-black-box AI decisions



\---



\## Current State (Week 3)



\### SQL Views Ready for AI (43 Total)



\*\*Data Aggregation Views (22 basic KPI views)\*\*

\- Operational, Workforce, Financial, Quality metrics

\- Prepared data foundation for reasoning layer



\*\*Advanced Analytics Views (18 specialized views)\*\*

\- Cohort analysis, time-series, comparative, predictive

\- Flag anomalies, identify patterns, score risk



\*\*AI-Ready Views (2 specialized views)\*\*

\- `v\_anomaly\_detection\_flags` - Surfaces issues with context

\- `v\_care\_quality\_reasoning` - Multi-factor analysis prepared for interpretation



\*\*Master Dashboard (1 aggregated view)\*\*

\- Single row with 35+ metrics + predictive indicators

\- Feeds Power BI and Claude API



\---



\## Week 4-6: Power BI Dashboard + Claude Layer



\### Phase 1: Power BI Dashboard

\- 5-page interactive dashboard

\- Connected to 43 SQL views

\- Master summary + 4 detail pages

\- Real-time data refresh



\### Phase 2: Claude API Integration (Weeks 5-6)

Add reasoning layer to dashboard:

