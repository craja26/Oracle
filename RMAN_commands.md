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


















