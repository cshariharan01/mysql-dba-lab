# Incident Runbook: Application Database Connectivity & Authentication Failures
**Incident ID**: INC-DB-004  
**Severity**: Sev-1 / Sev-2 Outage  
**Target Environment**: `dba_lab` (MySQL 8.0.30)  
**Applicable Roles**: Application Support Engineer, Technical Support Lead

---

## 1. Symptom & Error Triggers
* **Scenario A (Authentication Failure)**:  
  Application logs report: `ERROR 1045 (28000): Access denied for user 'app_user'@'192.168.1.50' (using password: YES)`.
* **Scenario B (Permission Denied)**:  
  Application feature throws: `ERROR 1142 (42000): CREATE/DROP/ALTER command denied to user 'app_user'@'localhost' for table 'pol_policy_v2'`.
* **Scenario C (Network/Port Unreachable)**:  
  Application times out with: `ERROR 2003 (HY000): Can't connect to MySQL server on '10.0.0.15' (10061)`.

---

## 2. Seven-Point Connection Troubleshooting Checklist

When diagnosing connectivity issues, follow this structured triage hierarchy:

```text
[1. Service State]   --> Is mysqld running? (Get-Service MySQL80 / systemctl status mysql)
       |
[2. Listener & Port] --> Is port 3306 listening? (Get-NetTCPConnection -LocalPort 3306)
       |
[3. Firewall]        --> Is port 3306 blocked between app host and DB? (Test-NetConnection)
       |
[4. Account & Host]  --> Does 'user'@'host' pattern match the incoming client IP?
       |
[5. Password/Plugin] --> Is caching_sha2_password or mysql_native_password expected?
       |
[6. Grant Privileges]--> Does user have SELECT/INSERT/UPDATE on the specific schema/table?
       |
[7. Max Connections] --> Has server reached max_connections threshold?
```

---

## 3. Detailed Triage & Diagnostic Steps

### Step 1: Verify Windows Service & Port Listener
```powershell
Get-Service MySQL80
Get-NetTCPConnection -LocalPort 3306 -State Listen
```

### Step 2: Account Host Wildcard & IP Matching Inspection
In MySQL, an account is identified by both **`username` AND `hostname`**:
* `'app_user'@'localhost'` only permits local socket / loopback connections.
* If the application connects from an external server (e.g. `192.168.1.50`), MySQL rejects it unless `'app_user'@'%'` or `'app_user'@'192.168.1.%'` exists!

To inspect:
```sql
SELECT user, host, plugin, account_locked 
FROM mysql.user 
WHERE user = 'app_user';
```

### Step 3: Verify Specific Grants
```sql
SHOW GRANTS FOR 'app_user'@'localhost';
```

---

## 4. Remediation Procedures

### Fix A: Expand Host Binding for Remote App Servers
```sql
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED WITH caching_sha2_password BY 'AppUserSecurePass!2026';
GRANT SELECT, INSERT, UPDATE, DELETE ON dba_lab.* TO 'app_user'@'%';
FLUSH PRIVILEGES;
```

### Fix B: Legacy Application Authentication Plugin (If App Driver is older than 8.0)
Older JDBC / PHP / Python drivers do not support `caching_sha2_password`:
```sql
ALTER USER 'app_user'@'%' IDENTIFIED WITH mysql_native_password BY 'AppUserSecurePass!2026';
FLUSH PRIVILEGES;
```

---

## 5. Post-Remediation Validation
Test connectivity directly from the application server or CLI:
```powershell
mysql -u app_user -h 127.0.0.1 -P 3306 -p"AppUserSecurePass!2026" -e "SELECT CURRENT_USER(), DATABASE();"
```
Ensure zero connection drops and confirm successful response.

