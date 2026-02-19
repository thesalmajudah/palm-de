# Performance Optimization & Quality Assurance

> **Technical guide for optimizing data pipeline performance and maintaining data quality**

## Table of Contents

- [Priority Optimization Changes](#priority-optimization-changes)
- [SQL Quality Issues & Fixes](#sql-quality-issues--fixes) 
- [Performance Investigation Process](#performance-investigation-process)
- [Team Communication Template](#team-communication-template)

---

## Priority Optimization Changes

**Next 30 Minutes - Immediate Impact**

| Rank | Change | Why / Impact |
|------|--------|--------------|
| **1** | Add clustered or partitioned index on `(company_id, date)` (or use table partitioning if supported) | The current query scans the full table for every run. Partitioning or clustering dramatically reduces I/O for GROUP BY. **Most immediate performance improvement.** |
| **2** | Pre-aggregate daily incremental totals into a staging table | Instead of scanning the full `fact_events` daily, only aggregate new data. Reduces compute by orders of magnitude for a growing table. |
| **3** | Ensure column pruning / select only necessary columns in upstream tables | `SELECT *` can unnecessarily scan wide tables. Selecting only `company_id, date, events` minimizes memory usage. |

### Rationale

- **Index/partitioning** gives the largest immediate speed-up
- **Incremental aggregation** prevents full-table scans over time
- **Column pruning** is easy, low-risk improvement

---

## SQL Quality Issues & Fixes

### 1. **No Handling of Duplicates**

**Problem:** If `fact_events` has repeated events (e.g., API retries), `SUM(events)` overcounts.

**Fix:** Deduplicate by a unique event key before aggregation.

```sql
SELECT company_id, date, SUM(events) AS events
FROM (
    SELECT DISTINCT event_id, company_id, date, events
    FROM fact_events
) t
GROUP BY company_id, date;
```

### 2. **No Incremental / Partition Awareness**

**Problem:** Current query scans the entire `fact_events` daily → very slow.

**Fix:** Only process new/updated partitions via a `WHERE date >= <last_processed>` clause.

### 3. **Potential Nulls / Missing Data**

**Problem:** `events` may be `NULL` in the source → aggregation could produce unexpected `NULL` totals.

**Fix:** Coalesce nulls:

```sql
SUM(COALESCE(events, 0)) AS events
```
## Performance Investigation Process

**If encountering a 3+ hour daily run, approach step-by-step:**

### 1. Check Query Execution Plan
- Look for full table scans, missing indexes, or shuffles (in Spark/distributed engines)

### 2. Measure Table Size & Row Counts
- See if table growth is causing full-table aggregation

### 3. Check for Duplicate or Overlapping Data
- Compare raw API totals vs `fact_events` → identify where totals diverge

### 4. Profile Upstream Transformations
- Identify slow joins, transformations, or wide scans

## Team Communication Template

### Daily Performance Update

**Message:**
We'll apply a temporary performance fix by clustering/partitioning `fact_events` on `(company_id, date)` to speed up daily aggregation.

**Important Notes:**
- **Caveat:** The new pre-aggregated totals may not include late-arriving events until the next run
- **Analysts should expect:** Small discrepancies vs. raw API for a day or two; please flag any anomalies
- **Next steps:** Full deduplication and rolling backfill planned for next sprint – we'll communicate when complete

**Contact:** Data Engineering team for questions or issues
