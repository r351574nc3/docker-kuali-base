#!/bin/sh

source /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh
/u01/app/oracle/product/11.2.0/xe/bin/sqlplus / as sysdba<<EOL
STARTUP
EXIT
EOL
