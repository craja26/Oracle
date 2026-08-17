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

STARTUP;
ALTER PLUGGABLE DATABASE ALL OPEN;
ALTER PLUGGABLE DATABASE ALL SAVE STATE;
EXIT;


############# Regular important commands
# Instance running unda?
ps -ef | grep pmon

# Listener status
lsnrctl status

# Database start
sqlplus / as sysdba
STARTUP;

# Database stop (clean)
SHUTDOWN IMMEDIATE;

# PDBs status
SHOW PDBS;

# Alert log
tail -100 /u01/app/oracle/diag/rdbms/orclcdb/ORCLCDB/trace/alert_ORCLCDB.log




