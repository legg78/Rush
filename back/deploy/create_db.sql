CREATE DATABASE SV
   USER SYS IDENTIFIED BY SYS1
   USER SYSTEM IDENTIFIED BY SYSTEM1
   LOGFILE GROUP 1 ('/oradata/sv/redo01.log') SIZE 500M,
           GROUP 2 ('/oradata/sv/redo02.log') SIZE 500M,
           GROUP 3 ('/oradata/sv/redo03.log') SIZE 500M,
           GROUP 4 ('/oradata/sv/redo04.log') SIZE 500M,
           GROUP 5 ('/oradata/sv/redo05.log') SIZE 500M
   MAXLOGFILES  24
   MAXLOGMEMBERS 2
   MAXLOGHISTORY 1
   MAXDATAFILES 200
   MAXINSTANCES 1
   CHARACTER SET AL32UTF8
   NATIONAL CHARACTER SET AL16UTF16
   DATAFILE '/oradata/sv/system01.dbf' SIZE 512M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED
   EXTENT MANAGEMENT LOCAL
   SYSAUX DATAFILE '/oradata/sv/sysaux01.dbf' SIZE 512M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED
   DEFAULT TEMPORARY TABLESPACE temp_tbs
      TEMPFILE '/oradata/sv/temp01.dbf' SIZE 2048M REUSE
   UNDO TABLESPACE undo_tbs
      DATAFILE '/oradata/sv/undo01.dbf'
      SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

@?/rdbms/admin/catalog.sql;

@?/rdbms/admin/catproc.sql;

@?/rdbms/admin/dbmssupp.sql;

CREATE TABLESPACE xml_data_tbs
DATAFILE '/oradata/sv/xml01.dbf' SIZE 10M REUSE AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

@?/rdbms/admin/catqm.sql XMLDB xml_data_tbs temp_tbs YES;

conn system/SYSTEM1;

@?/sqlplus/admin/pupbld.sql

conn / as sysdba;

ALTER SYSTEM SET NLS_LENGTH_SEMANTICS=CHAR;
