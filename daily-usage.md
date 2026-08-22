## 1. Quick health check
```bash
su - oracle
ps -ef | grep pmon
lsnrctl status
sqlplus -s / as sysdba << EOF
SELECT status FROM v\$instance;
SHOW PDBS;
EXIT;
EOF

# Alert log location
tail -50 /u01/app/oracle/diag/rdbms/orclcdb/ORCLCDB/trace/alert_ORCLCDB.log


# 2. Start oracle incase it is down
# Listener start
su - oracle
lsnrctl start

# Database start
sqlplus / as sysdba
```
```sql
STARTUP;
ALTER PLUGGABLE DATABASE ALL OPEN;
ALTER PLUGGABLE DATABASE ALL SAVE STATE;
EXIT;
```
############# Regular important commands
```bash
# Instance running unda?
ps -ef | grep pmon

# Listener status
lsnrctl status

# Database start
sqlplus / as sysdba
```
```sql
STARTUP;

# Database stop (clean)
SHUTDOWN IMMEDIATE;

# PDBs status
SHOW PDBS;
```
```bash
# Alert log
tail -100 /u01/app/oracle/diag/rdbms/orclcdb/ORCLCDB/trace/alert_ORCLCDB.log
```
```sql
-- check the current PDB name
SHOW CON_NAME;

SELECT sys_context('USERENV','CON_NAME') FROM dual;

SELECT name, open_mode FROM v$pdbs;
```
### Basic DBA tasks
## 1. Tablespace create + Datafile add
```sql
-- system or sys tho connect avvu
sqlplus system/Oracle_123@ORCLPDB1

-- New tablespace create
CREATE TABLESPACE app_data
DATAFILE '/u01/oradata/ORCLCDB/ORCLPDB1/app_data01.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 50M MAXSIZE 2G;

-- Verify
SELECT tablespace_name, status, contents FROM dba_tablespaces;
SELECT file_name, bytes/1024/1024 MB FROM dba_data_files;
```
## 2. User create + Privileges
```sql
CREATE USER app_user IDENTIFIED BY App_123
DEFAULT TABLESPACE app_data
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON app_data;

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE TO app_user;
GRANT CONNECT, RESOURCE TO app_user;
```
## 3. Test the new user
```sql
CONN app_user/App_123@ORCLPDB1

CREATE TABLE test_table (id NUMBER, name VARCHAR2(50));
INSERT INTO test_table VALUES (1, 'Oracle DBA Practice');
COMMIT;

SELECT * FROM test_table;
```
### Settings for SQL*Plus better output
```sql
-- Every session starting
SET LINESIZE 200
SET PAGESIZE 100
SET LONG 10000
COLUMN file_name FORMAT A70
COLUMN tablespace_name FORMAT A20
```






