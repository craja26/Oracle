```bash
# create HR schema from sample schema
# sample schema scripts location:
cd $ORACLE_HOME/demo/schema
ls -ltrh

# HR schema install
sqlplus system/Oracle_123@ORCLPDB1
```
```sql
-- run sql 
@$ORACLE_HOME/demo/schema/human_resources/hr_main.sql


-- Password adigithe: Oracle_123
-- Tablespace: USERS
-- Temp tablespace: TEMP
-- Log path: /tmp

----- Quick verification
-- switch connection to hr user
CONN hr/Oracle_123@ORCLPDB1

SELECT table_name FROM user_tables ORDER BY 1;

SELECT COUNT(*) FROM employees;
SELECT COUNT(*) FROM departments;

SHOW USER;
SHOW CON_NAME;

EXIT;
```
```bash
# if you want to conenct directly using hr user
sqlplus hr/Oracle_123@ORCLPDB1

# or
sqlplus hr/Oracle_123@ORCLPDB1 as sysdba   -- (sysdba avasaram ledu HR ki)

##-- Common ways to conenct
# 1. Easy Connect
sqlplus hr/Oracle_123@oracle19c-lab:1521/orclpdb1

# 2. Using tnsnames
sqlplus hr/Oracle_123@ORCLPDB1
```

