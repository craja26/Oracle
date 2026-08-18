#1. System Update (Recommended)
dnf update -y

#2. Oracle Preinstall Package
dnf install -y oracle-database-preinstall-19c

#3. Directory Structure Create
mkdir -p /u01/app/oracle/product/19c/dbhome_1
mkdir -p /u01/oradata
chown -R oracle:oinstall /u01
chmod -R 775 /u01

#4. Oracle user password set (optional kani useful)
passwd oracle

#5. Firewall lo port 1521 open
firewall-cmd --permanent --add-port=1521/tcp
firewall-cmd --reload

#6 Switch oracle user
su - oracle

#7. Extract zip file to correct location
cd /home/oracle
unzip -q LINUX.X64_193000_db_home.zip -d /u01/app/oracle/product/19c/dbhome_1

#8. Create Response File - Run below command in oracle user
cat > /home/oracle/db_install.rsp << EOF
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v19.0.0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=$(hostname)
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en
ORACLE_HOME=/u01/app/oracle/product/19c/dbhome_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.OSDBA_GROUP=dba
oracle.install.db.OSOPER_GROUP=oper
oracle.install.db.OSBACKUPDBA_GROUP=backupdba
oracle.install.db.OSDGDBA_GROUP=dgdba
oracle.install.db.OSKMDBA_GROUP=kmdba
oracle.install.db.OSRACDBA_GROUP=racdba
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true
EOF

#9. Verify whether ip address is present in /etc/hosts file if not add it. Example.
su -
cat /etc/hosts
echo "192.168.2.130   oracle19c-lab   oracle19c-lab" >> /etc/hosts


#10. Switch to oracle user and set environment variable
su - oracle
export CV_ASSUME_DISTID=OEL8

#11. run silent installer
cd /u01/app/oracle/product/19c/dbhome_1
./runInstaller -silent -responseFile /home/oracle/db_install.rsp -ignorePrereqFailure

: <<'END_COMMENT'
[oracle@oracle19c-lab dbhome_1]$ ./runInstaller -silent -responseFile /home/oracle/db_install.rsp -ignorePrereqFailure
Launching Oracle Database Setup Wizard...

[WARNING] [INS-32047] The location (/u01/app/oraInventory) specified for the central inventory is not empty.
   ACTION: It is recommended to provide an empty location for the inventory.
The response file for this session can be found at:
 /u01/app/oracle/product/19c/dbhome_1/install/response/db_2026-08-17_01-42-14AM.rsp

You can find the log of this install session at:
 /tmp/InstallActions2026-08-17_01-42-14AM/installActions2026-08-17_01-42-14AM.log

As a root user, execute the following script(s):
        1. /u01/app/oraInventory/orainstRoot.sh
        2. /u01/app/oracle/product/19c/dbhome_1/root.sh

Execute /u01/app/oraInventory/orainstRoot.sh on the following nodes:
[oracle19c-lab]
Execute /u01/app/oracle/product/19c/dbhome_1/root.sh on the following nodes:
[oracle19c-lab]


Successfully Setup Software.
Moved the install session logs to:
 /u01/app/oraInventory/logs/InstallActions2026-08-17_01-42-14AM
 
END_COMMENT

#12. Switch to root, run two commands
su -
/u01/app/oraInventory/orainstRoot.sh
/u01/app/oracle/product/19c/dbhome_1/root.sh


#13. Oracle User Environment Setup
su - oracle
# setup environment variables in profile
cat >> ~/.bash_profile << EOF

# Oracle Environment
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19c/dbhome_1
export ORACLE_SID=ORCLCDB
export PATH=\$ORACLE_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:\$LD_LIBRARY_PATH
EOF
# apply it
source ~/.bash_profile
# verify
echo $ORACLE_HOME
echo $ORACLE_SID

#14. Create database (Silent DBCA)
# create database (CDB + one PDB)
dbca -silent \
-createDatabase \
-templateName General_Purpose.dbc \
-gdbName ORCLCDB \
-sid ORCLCDB \
-sysPassword Oracle_123 \
-systemPassword Oracle_123 \
-createAsContainerDatabase true \
-numberOfPDBs 1 \
-pdbName ORCLPDB1 \
-pdbAdminPassword Oracle_123 \
-emConfiguration NONE \
-datafileDestination /u01/oradata \
-storageType FS \
-characterSet AL32UTF8 \
-totalMemory 2048

# here ORCLCDB is container database (CDB) - Main contrainer (root) - Database management, common users
# ORCLPDB1 Pluggabel database (PDB) - Actual application database 
####### verify
# run as oracle user
sqlplus / as sysdba

SELECT name, open_mode, cdb FROM v$database;

SHOW PDBS;

ALTER PLUGGABLE DATABASE ORCLPDB1 OPEN;
ALTER PLUGGABLE DATABASE ALL SAVE STATE;

EXIT;



########### Auto start ###########
# update oratab file last line value from N to Y
vim /etc/oratab
# change below line value to Y
ORCLCDB:/u01/app/oracle/product/19c/dbhome_1:Y

# rc.local file create
chmod +x /etc/rc.d/rc.local

cat >> /etc/rc.d/rc.local << EOF

# Oracle Start
su - oracle -c "lsnrctl start"
su - oracle -c "sqlplus / as sysdba << EOF
STARTUP;
ALTER PLUGGABLE DATABASE ALL OPEN;
ALTER PLUGGABLE DATABASE ALL SAVE STATE;
EXIT;
EOF"
EOF

# systemctl enable 
systemctl enable rc-local







