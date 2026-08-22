RMAN tho proper backup (especially archivelog) theeyali ante ARCHIVELOG mode enable cheyali.
```bash
sqlplus / as sysdba
```
```sql
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ALTER SYSTEM ARCHIVE LOG CURRENT;   -- optional

ARCHIVE LOG LIST;
```
`Database log mode` → Archive Mode kanipisthe success.

RMAN lo backup
```bash
rman target /
BACKUP DATABASE PLUS ARCHIVELOG DELETE INPUT;
LIST BACKUP SUMMARY;
```
Check backup details
```bash
LIST BACKUP;
# or more detailed
LIST BACKUP OF DATABASE;
```
Output `Piece Name` is full path.
Common default locations:
```bash
# Check FRA (Fast recovery area)
SHOW PARAMETER db_recovery_file_dest;

# Or check actual backup pieces
ls -l $ORACLE_HOME/dbs/
ls -l /u01/app/oracle/fast_recovery_area/   # if exists
```
---
Configure Backup location
Best practice (FRA setting)
Create directory
```bash
mkdir -p /u01/app/oracle/fast_recovery_area
chown -R oracle:oinstall /u01/app/oracle/fast_recovery_area
chmod -R 775 /u01/app/oracle/fast_recovery_area
```
Set the parameter
```sql
sqlplus / as sysdba

ALTER SYSTEM SET db_recovery_file_dest_size = 10G SCOPE=BOTH;
ALTER SYSTEM SET db_recovery_file_dest = '/u01/app/oracle/fast_recovery_area' SCOPE=BOTH;
```
Verify
```sql
SHOW PARAMETER db_recovery_file_dest;
SHOW PARAMETER db_recovery_file_dest_size;
```

#### Qucik Test
Take a new backup after location change
```bash
rman target /
BACKUP DATABASE;
LIST BACKUP;
```
**Notes** RMAN remote connect
```bash
rman target sys/Oracle_123@192.168.2.130:1521/ORCLCDB
# or
rman target sys/Oracle_123@ORCLCDB

# Full format
rman target sys/password@//IP:1521/SERVICE_NAME
```

### RMAN Incremental Backup (Level 0 + Level 1)
| Type | Usage | Use Case |
|---|---|---|
| Level 0 | Full backup (base backup) | Weekly / Starting point |
| Level 1 | Level 0 taruvata change ayina blocks only | Daily backups |

#### Two types of Level 1:
- `Differential` (default) -> Last level 0 or Level 1 nunchi changes
- `Cumulative` -> Last Level 0 nunchi anni changes

##### Adavantages:
- Backup size + time tagguthundhi
- Network + storage save avuthindhi

##### Common Strategy (In companies):
- Sunday -> Level 0
- Mon-Sat -> Level 1

### Practice
**A. Level 0 Backup (Base)**
```bash
rman target /

BACKUP INCREMENTAL LEVEL 0 DATABASE PLUS ARCHIVELOG DELETE INPUT;
```
**B. Level 1 Backup (Incremental)**
```bash
BACKUP INCREMENTAL LEVEL 1 DATABASE PLUS ARCHIVELOG DELETE INPUT;
```
**Cumulative Level 1 (optional)**
```bash
BACKUP INCREMENTAL LEVEL 1 CUMULATIVE DATABASE;
```
---
Useful Commands
```bash
LIST BACKUP SUMMARY;
LIST BACKUP OF DATABASE;
REPORT NEED BACKUP;
```

---
# Scenario 1- RMAN recovery
#### Step 1: verify current datafiles
```bash
sqlplus / as sysdba
```
```sql
-- switch connection to PDB
ALTER SESSION SET CONTAINER = ORCLPDB1;
SHOW CON_NAME;

SELECT file# , name FROM v$datafile;

-- verify tablespaces + datafiles
SELECT tablespace_name, status FROM dba_tablespaces;

SELECT file_id, file_name, tablespace_name, bytes/1024/1024 AS MB 
FROM dba_data_files 
ORDER BY tablespace_name;
```
note the ORCLPDB1 related datafile (Example add_data or users datafile).
## Step 2: Tablespace offline + datafile delete
```sql
ALTER TABLESPACE app_data OFFLINE IMMEDIATE;
```
```bash
rm /u01/oradata/ORCLCDB/ORCLPDB1/app_data01.dbf
```
## Step 3: RMAN Restore + Recover
```bash
rman target /

RESTORE DATAFILE '/u01/oradata/ORCLCDB/ORCLPDB1/app_data01.dbf';
RECOVER DATAFILE '/u01/oradata/ORCLCDB/ORCLPDB1/app_data01.dbf';
```
## Step 4: Tablespace Online
```sql
ALTER TABLESPACE app_data ONLINE;
```
## Check tables after recover
```sql
CONN app_user/App_123@ORCLPDB1   -- or hr user

SELECT table_name FROM user_tables;

SELECT * FROM test_table;   -- earlier create chesina table
```

### Datafile missing / corrupt ayite manaki ela telustaadhi?
Common ways:
**A. Alert Log**
```bash
tail -100 /u01/app/oracle/diag/rdbms/orclcdb/ORCLCDB/trace/alert_ORCLCDB.log
```
Error messages (ORA-01157, ORA-01110 etc.)
**B. Database open avvadam fail avuthundhi**
```sql
STARTUP;
```
Error vastundhi
**C. Query tho check cheyyadam**
```sql
SELECT file#, name, status FROM v$datafile WHERE status != 'ONLINE';
SELECT * FROM v$recover_file;
SELECT * FROM v$recovery_file_status;
```
**D. RMAN validation**
```bash
RMAN> VALIDATE DATABASE;
RMAN> VALIDATE DATAFILE <number>;
```
**E. Users complaints**
Application nunchi “unable to extend” or “file not found” errors.
---

# Scenario 2- Complete database loss
Warning: Idhi destructive scenario. Careful ga follow cheyyaali.
**High-leve steps:**
1. Current control file + datafiles + redo logs anni list ayyayi ani assume cheddam
2. RMAN backup undi kabatti recover cheyyochu
3. Steps:
  - Startup nomount
  - Restore control file from autobackup
  - Mount database
  - Restore database
  - Recover database
  - Open with resetlogs
---

**Practical start**
Mundu current environment safe ga vundataaniki Full backup teesukondaam
```bash
rman target /
BACKUP DATABASE PLUS ARCHIVELOG;
EXIT;
```
**Step 1: Database ni shutdown cheyyi**
```bash
sqlplus / as sysdba
SHUTDOWN ABORT;
EXIT;
```
**Step 2: Datafiles + Control files + Redo logs delete cheyyi (loss simulate)**
```bash
# Careful ga
rm -rf /u01/oradata/ORCLCDB/*
rm -f /u01/app/oracle/product/19c/dbhome_1/dbs/control*
rm -f /u01/app/oracle/product/19c/dbhome_1/dbs/*.log
```
(Fast Recovery Area lo backups undali, touch cheyakudadu)
**Step 3: RMAN tho Recover**
```bash
rman target /
```
```bash
STARTUP NOMOUNT;

RESTORE CONTROLFILE FROM AUTOBACKUP;
ALTER DATABASE MOUNT;

RESTORE DATABASE;
RECOVER DATABASE;

ALTER DATABASE OPEN RESETLOGS;
```
`RESETLOGS` success ayyaaka - Final steps:
Connect database server
```bash
sqlplus / as sysdba
```
```sql
SELECT status FROM v$instance;
SHOW PDBS;

ALTER DATABASE OPEN;
ALTER PLUGGABLE DATABASE ALL OPEN;
ALTER PLUGGABLE DATABASE ALL SAVE STATE;

SELECT status FROM v$instance;
SHOW PDBS;
```
Output lo:

Instance STATUS = OPEN
ORCLPDB1 = READ WRITE

kanipisthe Complete Database Loss recovery successful.

---
**Important Notes:**
- `OPEN RESETLOGS` tarvata kotha incarnation start avuthundi
- Tarvata immediate ga kotha full backup theeskovali

**Recover Error**
Archive log file disk lo miss avvadam valla error vachindhi.
```text
RMAN> RECOVER DATABASE;

Starting recover at 23-AUG-26
using channel ORA_DISK_1

starting media recovery

archived log for thread 1 with sequence 19 is already on disk as file /u01/app/oracle/fast_recovery_area/ORCLCDB/archivelog/2026_08_22/o1_mf_1_19_o8n68lws_.arc
archived log file name=/u01/app/oracle/fast_recovery_area/ORCLCDB/archivelog/2026_08_22/o1_mf_1_19_o8n68lws_.arc thread=1 sequence=19
unable to find archived log
archived log thread=1 sequence=20
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of recover command at 08/23/2026 00:04:43
RMAN-06054: media recovery requesting unknown archived log for thread 1 with sequence 20 and starting SCN of 2705434
```
Andhuke `RECOVER` command lo small change chesi re-run chesa
```bash
RECOVER DATABASE UNTIL SEQUENCE 20 THREAD 1;
# another way
RUN {
  SET UNTIL SEQUENCE 20 THREAD 1;
  RECOVER DATABASE;
}
ALTER DATABASE OPEN RESETLOGS;
```
`UNTIL SEQUENCE 20 THREAD 1` enduku add chesam.
- **SEQUENCE 20** → Archive log sequence number 20 mundu varaku recover cheyali ani
- **THREAD 1** → Single instance lo thread number (normal ga 1)
Ante: Sequence 19 varaku apply chesi, 20 kosam wait cheyakunda aagipovatam.

























