# 30-Minute Implementation Prioritization Plan

> **Critical Decision Framework**: What to implement first when time is limited

## Scenario

We have **30 minutes** before tomorrow's production run.
We must choose one part of the pipeline to implement or harden.


**Priority: Bronze API Ingestion (With Alerting)**
Implement First
Product API → Azure Function → ADLS Bronze
+ Basic error handling
+ Failure alerts

Why This First?
**1. No Data → No Pipeline**

If raw data does not land successfully:

Silver cannot run

Gold cannot be built

Dashboard cannot refresh

**Bottom Line**: Bronze ingestion is the foundation of the entire pipeline.

#### 2. **Highest Operational Risk**

API ingestion represents the **most failure-prone component** in the system:

- **Network instability** - Internet connectivity issues
- **Rate limiting** - API throttling and quotas  
- **Authentication/token expiration** - Service principal issues
- **Schema drift** - Unexpected API response changes
- **Pagination issues** - Large result set handling

**Risk Mitigation**: Ensuring ingestion stability reduces the largest operational risk.

#### 3. **Enables Full Recoverability**

When Bronze works correctly:

```
✅ Raw source-of-truth data preserved
✅ Silver and Gold can be rebuilt anytime  
✅ Backfills become possible
✅ Transform logic can evolve safely
```

**Guarantee**: Bronze ensures complete pipeline recoverability.

#### 4. **Production Observability**

**Minimum viable monitoring:**

```yaml
Error Handling:
  - Fail fast on API errors
  - Retry policy: 3 attempts with exponential backoff
  - Timeout: 5 minutes per request

Alerting:
  - Logic App notification on failure
  - Azure Monitor integration  
  - Email alerts to on-call team
```

**Outcome**: Detect and respond to issues before business users are impacted.

---

## Components to **Explicitly Postpone**

> These items can be implemented after the foundation is stable

### 1. Advanced Gold Layer Logic

**Postpone for later:**
- 7-day rolling aggregations
- Churn risk flag logic  
- Business scoring enhancements
- Complex analytical functions

**Rationale:**  
These are business-layer improvements that add value but are not critical for basic pipeline operation. They can be safely added after data stability is confirmed.

### 2. Performance Optimization

**Postpone for later:**
- Partition tuning and optimization
- Index creation and maintenance
- Table clustering strategies  
- Incremental watermark refinements
- Query performance tuning

**Rationale:**  
Optimization is secondary to correctness and availability. Focus on getting data flowing first, then optimize for speed.

### 3. Pipeline Engineering Polish

**Postpone for later:**
- Master orchestration pipeline setup
- CI/CD pipeline automation  
- Advanced parameterization
- Code refactoring and cleanup
- Comprehensive logging framework

**Rationale:**  
These improve maintainability and developer experience but do not block tomorrow's production run. Prioritize functional delivery over engineering elegance.

---

## Conclusion

**Decision**: Implement Bronze API ingestion with basic error handling and alerting.

**This choice maximizes:**
- ✅ Pipeline reliability and recoverability
- ✅ Operational visibility and monitoring  
- ✅ Foundation for future enhancements
- ✅ Time-to-value for tomorrow's production run

### Next Steps After Success

1. **Monitor** Bronze ingestion for 24-48 hours
2. **Implement** Silver layer transformations  
3. **Add** Gold layer business logic
4. **Optimize** performance based on real usage patterns

---
