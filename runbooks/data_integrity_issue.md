# Incident Runbook: Production Data Discrepancy & Safe Fix Workflow
**Incident ID**: INC-DB-006  
**Severity**: Sev-2 / High  
**Target Environment**: `dba_lab` (MySQL 8.0.30)  
**Applicable Roles**: Application Support Engineer, Lead Data Support Specialist

---

## 1. Incident Scenario & Context
* **Symptom**: Underwriters report that quote calculations in `QOT_QUOTE_V2` do not match the expected state rules, or orphaned quotes exist without corresponding submissions.
* **Support Engineer Responsibility**: Diagnose the bad data, assess business impact, construct a safe transactional correction script, validate in pre-prod/isolated restore schema first, and execute in production with rollback capability.

---

## 2. Immediate Diagnostic Triage

### Step 1: Query the Inconsistent Records
```sql
-- Identify orphaned quotes with invalid submission references
SELECT 
    q.ID AS quote_id, 
    q.QUOTE_NUMBER, 
    q.SUBMISSION_ID, 
    q.QUOTE_STATUS, 
    q.CREATED_DATE
FROM dba_lab.qot_quote_v2 q
LEFT JOIN dba_lab.sub_submission s ON q.SUBMISSION_ID = s.ID
WHERE s.ID IS NULL AND q.ACTIVE = 'Y';
```

### Step 2: Quantify Blast Radius (How Many Records Affected?)
```sql
SELECT COUNT(*) AS affected_rows FROM dba_lab.qot_quote_v2 q
LEFT JOIN dba_lab.sub_submission s ON q.SUBMISSION_ID = s.ID
WHERE s.ID IS NULL AND q.ACTIVE = 'Y';
```

---

## 3. Four-Step Safe Data Fix Governance (Interview Highlight)

In an Accenture Application Support role, applying a data fix to production requires strict governance:

```text
[1. Pre-Fix Backup]  --> Export target table/rows BEFORE touching data
         |
[2. Dry-Run / Test]  --> Run and validate update in dba_lab_restore first
         |
[3. Atomic Fix]      --> Execute inside START TRANSACTION with row-count verification
         |
[4. Audit Log]       --> Document ticket #, approver, rows changed, and verification
```

### Step 1: Pre-Fix Micro-Backup
Export the target rows to a recovery table before modifying:
```sql
CREATE TABLE dba_lab.backup_qot_quote_v2_INC006 AS
SELECT * FROM dba_lab.qot_quote_v2
WHERE SUBMISSION_ID NOT IN (SELECT ID FROM dba_lab.sub_submission);
```

### Step 2: Atomic Transactional Fix
```sql
START TRANSACTION;

-- Soft-deactivate orphaned quotes
UPDATE dba_lab.qot_quote_v2
SET ACTIVE = 'N',
    QUOTE_STATUS = 'INVALID_ORPHAN'
WHERE SUBMISSION_ID NOT IN (SELECT ID FROM dba_lab.sub_submission)
  AND ACTIVE = 'Y';

-- Crucial: Inspect affected rows before committing
SELECT ROW_COUNT() AS updated_rows;

-- If updated_rows matches expected blast radius:
COMMIT;
-- If updated_rows deviates unexpectedly:
-- ROLLBACK;
```

---

## 4. Post-Remediation Verification
Re-run the diagnostic query to confirm zero orphan active records remain:
```sql
SELECT COUNT(*) FROM dba_lab.qot_quote_v2 q
LEFT JOIN dba_lab.sub_submission s ON q.SUBMISSION_ID = s.ID
WHERE s.ID IS NULL AND q.ACTIVE = 'Y';
```
*(Expected: 0)*.

---

## 5. Rollback Plan (If Reversal is Requested)
```sql
START TRANSACTION;

UPDATE dba_lab.qot_quote_v2 q
JOIN dba_lab.backup_qot_quote_v2_INC006 b ON q.ID = b.ID
SET q.ACTIVE = b.ACTIVE,
    q.QUOTE_STATUS = b.QUOTE_STATUS;

COMMIT;
```

---

## 6. Root Cause Prevention
1. Add foreign key constraints where missing:
   ```sql
   -- Enforce referential integrity at engine level
   ALTER TABLE qot_quote_v2 
   ADD CONSTRAINT fk_quote_submission FOREIGN KEY (SUBMISSION_ID) REFERENCES sub_submission(ID);
   ```
2. Coordinate with application engineering to patch the asynchronous event worker creating records out-of-order.

