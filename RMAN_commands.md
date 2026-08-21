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
** A. Level 0 Backup (Base) **
```bash
rman target /

BACKUP INCREMENTAL LEVEL 0 DATABASE PLUS ARCHIVELOG DELETE INPUT;
```
** B. Level 1 Backup (Incremental) **
```bash
BACKUP INCREMENTAL LEVEL 1 DATABASE PLUS ARCHIVELOG DELETE INPUT;
```
** Cumulative Level 1 (optional) **
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
















