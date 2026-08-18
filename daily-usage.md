```bash
# 1. Quick health check
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

```bash
############# Regular important commands
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





