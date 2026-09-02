\# VisitOps Intelligence - SQL KPI Views



Complete documentation of all 22 production SQL views for domiciliary care analytics.



\---



\## Overview



| Domain | Views | Purpose |

|--------|-------|---------|

| \*\*Operational\*\* | 5 | Visit completion, lateness, types, daily trends |

| \*\*Workforce\*\* | 5 | Carer performance, utilization, reliability |

| \*\*Financial\*\* | 5 | Revenue, payments, profitability, rejections |

| \*\*Quality\*\* | 6 | Incidents, safeguarding, missed visits, severity |

| \*\*Dashboard\*\* | 1 | Master summary (all metrics in one row) |

| \*\*Total\*\* | \*\*22\*\* | |



\---



\## Operational KPIs (5 views)



\### v\_operational\_daily\_summary

\*\*What it answers:\*\* How many visits completed each day? How many missed or late?



\*\*Business question:\*\* Is operational performance trending up or down?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_operational\_daily\_summary LIMIT 7;

```



\*\*Fields:\*\* scheduled\_date, total\_scheduled\_visits, completed\_visits, missed\_visits, completion\_rate\_pct, late\_visits, avg\_lateness\_minutes



\---



\### v\_visit\_type\_summary

\*\*What it answers:\*\* Which visit types do we deliver most? What's the completion rate by type?



\*\*Business question:\*\* Are certain visit types riskier (higher miss rate)?



\*\*Example query:\*\*

```sql

SELECT visit\_type, completion\_rate\_pct FROM v\_visit\_type\_summary ORDER BY completion\_rate\_pct;

```



\*\*Fields:\*\* visit\_type, total\_visits, completed\_visits, missed\_visits, completion\_rate\_pct, avg\_lateness\_minutes



\---



\### v\_operational\_summary\_all\_time

\*\*What it answers:\*\* Overall operational health across entire data period.



\*\*Business question:\*\* What's our baseline performance?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_operational\_summary\_all\_time;

```



\*\*Fields:\*\* total\_visits, completed\_visits, missed\_visits, completion\_rate\_pct, late\_visits, late\_rate\_pct, avg\_lateness\_minutes, data\_start\_date, data\_end\_date, days\_of\_data



\---



\### v\_lateness\_analysis

\*\*What it answers:\*\* How late are visits? Distribution of lateness categories.



\*\*Business question:\*\* What's our safeguarding risk from lateness?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_lateness\_analysis;

```



\*\*Fields:\*\* lateness\_category, visit\_count, pct\_of\_all\_visits



\*\*Categories:\*\* On time | 1-15 minutes late | 16-30 minutes late | 30+ minutes late



\---



\### v\_completion\_by\_week

\*\*What it answers:\*\* Completion rate trend by week.



\*\*Business question:\*\* Is performance improving or declining?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_completion\_by\_week ORDER BY week DESC LIMIT 4;

```



\*\*Fields:\*\* week, total\_visits, completed\_visits, completion\_rate\_pct



\---



\## Workforce KPIs (5 views)



\### v\_carer\_performance

\*\*What it answers:\*\* Which carers are top performers? Who completes most visits?



\*\*Business question:\*\* Who should we recognize? Who needs support?



\*\*Example query:\*\*

```sql

SELECT name, completion\_rate\_pct, avg\_lateness\_minutes FROM v\_carer\_performance LIMIT 10;

```



\*\*Fields:\*\* carer\_id, name, employment\_type, total\_visits, completed\_visits, missed\_visits, completion\_rate\_pct, avg\_lateness\_minutes, days\_worked



\---



\### v\_carer\_utilization

\*\*What it answers:\*\* How are carers scheduled? Shifts per carer? Visits per shift?



\*\*Business question:\*\* Are we over/under-utilizing our workforce?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_carer\_utilization WHERE days\_scheduled > 30;

```



\*\*Fields:\*\* carer\_id, name, days\_scheduled, avg\_visits\_per\_shift, overtime\_shifts, total\_shifts



\---



\### v\_employment\_type\_summary

\*\*What it answers:\*\* Employed vs agency comparison. Who completes more?



\*\*Business question:\*\* Should we hire more permanent staff?



\*\*Example query:\*\*

```sql

SELECT employment\_type, completion\_rate\_pct FROM v\_employment\_type\_summary;

```



\*\*Fields:\*\* employment\_type, total\_carers, completed\_visits, missed\_visits, completion\_rate\_pct, total\_visits



\---



\### v\_carer\_lateness\_ranking

\*\*What it answers:\*\* Which carers have highest lateness rates?



\*\*Business question:\*\* Who needs punctuality coaching?



\*\*Example query:\*\*

```sql

SELECT name, late\_rate\_pct FROM v\_carer\_lateness\_ranking WHERE late\_rate\_pct > 10;

```



\*\*Fields:\*\* carer\_id, name, total\_visits, late\_visits, late\_rate\_pct, avg\_lateness\_when\_late\_minutes



\---



\### v\_high\_performing\_carers

\*\*What it answers:\*\* Who are our best performers? (>95% completion, 20+ visits)



\*\*Business question:\*\* Who should mentor others?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_high\_performing\_carers;

```



\*\*Fields:\*\* carer\_id, name, employment\_type, total\_visits, completion\_rate\_pct, avg\_lateness\_minutes



\---



\## Financial KPIs (5 views)



\### v\_financial\_by\_commissioner

\*\*What it answers:\*\* Revenue and payment status by each HSCP commissioner.



\*\*Business question:\*\* Which commissioners pay reliably?



\*\*Example query:\*\*

```sql

SELECT commissioner\_name, paid\_rate\_pct FROM v\_financial\_by\_commissioner ORDER BY total\_revenue DESC;

```



\*\*Fields:\*\* commissioner\_name, total\_invoices, visits\_invoiced, total\_revenue, avg\_invoice\_amount, paid\_invoices, pending\_invoices, rejected\_invoices, paid\_rate\_pct



\---



\### v\_revenue\_per\_visit

\*\*What it answers:\*\* How much do we earn per visit by commissioner?



\*\*Business question:\*\* Which commissioners are most profitable?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_revenue\_per\_visit ORDER BY revenue\_per\_visit DESC;

```



\*\*Fields:\*\* commissioner\_name, revenue\_per\_visit, total\_visits\_invoiced, total\_revenue



\---



\### v\_payment\_status\_summary

\*\*What it answers:\*\* Overall payment status. How much is paid/pending/rejected?



\*\*Business question:\*\* What's our cash flow impact?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_payment\_status\_summary;

```



\*\*Fields:\*\* payment\_status, invoice\_count, total\_amount, pct\_of\_invoices, pct\_of\_revenue



\---



\### v\_rejection\_analysis

\*\*What it answers:\*\* Which commissioners reject invoices? Why?



\*\*Business question:\*\* Which commissioners need contract review?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_rejection\_analysis WHERE rejection\_rate\_pct > 5;

```



\*\*Fields:\*\* commissioner\_name, rejected\_count, rejected\_amount, total\_invoices, rejection\_rate\_pct



\---



\### v\_financial\_summary\_all\_time

\*\*What it answers:\*\* Overall financial performance. Total revenue, paid, pending.



\*\*Business question:\*\* What's our financial health?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_financial\_summary\_all\_time;

```



\*\*Fields:\*\* total\_invoices, total\_visits\_invoiced, total\_revenue, avg\_invoice\_amount, paid\_revenue, pending\_revenue, rejected\_revenue, overall\_revenue\_per\_visit, earliest\_invoice, latest\_invoice



\---



\## Quality KPIs (6 views)



\### v\_incident\_rate\_summary

\*\*What it answers:\*\* How many incidents per 1,000 visits?



\*\*Business question:\*\* Are we meeting CQC standards?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_incident\_rate\_summary;

```



\*\*Fields:\*\* incidents\_per\_1000\_visits, total\_incidents, total\_visits, missed\_visits, missed\_visit\_rate\_pct



\*\*CQC Context:\*\* Lower is better. Benchmarks vary by region.



\---



\### v\_incident\_breakdown

\*\*What it answers:\*\* What types of incidents? How severe?



\*\*Business question:\*\* What are our main quality risks?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_incident\_breakdown WHERE pct\_of\_total\_incidents > 10;

```



\*\*Fields:\*\* incident\_type, severity, incident\_count, pct\_of\_total\_incidents



\*\*Types:\*\* missed\_visit | late\_visit | complaint | safeguarding\_concern



\---



\### v\_missed\_visit\_analysis

\*\*What it answers:\*\* When and why do we miss visits?



\*\*Business question:\*\* Are misses concentrated on certain days/carers?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_missed\_visit\_analysis WHERE missed\_visits > 5 ORDER BY scheduled\_date DESC;

```



\*\*Fields:\*\* scheduled\_date, missed\_visits, affected\_service\_users, carers\_with\_misses



\---



\### v\_safeguarding\_incidents

\*\*What it answers:\*\* Safeguarding concerns and complaints tracked separately.



\*\*Business question:\*\* Do we have safeguarding trends?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_safeguarding\_incidents;

```



\*\*Fields:\*\* incident\_type, severity, incident\_count, affected\_visits, first\_reported, most\_recent



\---



\### v\_severity\_distribution

\*\*What it answers:\*\* How many high/medium/low severity incidents?



\*\*Business question:\*\* Are we catching serious issues early?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_severity\_distribution;

```



\*\*Fields:\*\* severity, incident\_count, pct\_of\_incidents



\---



\### v\_quality\_summary\_all\_time

\*\*What it answers:\*\* Overall quality health. Completion rate + incident rate + severity breakdown.



\*\*Business question:\*\* How should we present quality to CQC?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_quality\_summary\_all\_time;

```



\*\*Fields:\*\* total\_visits, completed\_visits, missed\_visits, completion\_rate\_pct, total\_incidents, incidents\_per\_1000\_visits, high\_severity\_incidents, medium\_severity\_incidents, data\_start\_date, data\_end\_date



\---



\## Master Dashboard (1 view)



\### v\_dashboard\_kpi\_summary

\*\*What it answers:\*\* All key metrics in ONE ROW for Power BI.



\*\*Business question:\*\* What's our overall performance at a glance?



\*\*Example query:\*\*

```sql

SELECT \* FROM v\_dashboard\_kpi\_summary;

```



\*\*Contains:\*\* 35+ metrics spanning all domains (operational, workforce, financial, quality)



\*\*Use case:\*\* Power BI pulls this single view to feed dashboard cards and visualizations.



\---



\## How to Use These Views



\### For Daily Operations

```sql

\-- Check yesterday's performance

SELECT \* FROM v\_operational\_daily\_summary LIMIT 1;



\-- Who are today's top carers?

SELECT name, completion\_rate\_pct FROM v\_carer\_performance LIMIT 5;

```



\### For Financial Reporting

```sql

\-- Revenue by commissioner

SELECT \* FROM v\_financial\_by\_commissioner;



\-- Payment status

SELECT \* FROM v\_payment\_status\_summary;

```



\### For CQC Readiness

```sql

\-- Quality metrics

SELECT \* FROM v\_quality\_summary\_all\_time;



\-- Incident trends

SELECT \* FROM v\_incident\_rate\_summary;

```



\### For Power BI Dashboard

```sql

\-- Single row with all metrics

SELECT \* FROM v\_dashboard\_kpi\_summary;

```



\---



\## Performance Notes



\- All views use efficient SQL aggregations

\- Foreign key relationships ensure data integrity

\- Views are read-only (no INSERT/UPDATE on views)

\- Suitable for real-time dashboard updates

\- Can handle 100K+ visits without performance degradation



\---



\## View Dependencies







\---



\## Author



VisitOps Intelligence - Domiciliary Care Analytics Platform



Built for NHS Scotland Health \& Social Care Partnerships and care providers.



\---



\## Last Updated



Week 2, Saturday - All views documented and tested.

