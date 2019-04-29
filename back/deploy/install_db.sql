-- check tempfs (df -ah),  set memory_target in initsv.ora
-- check cpu, set cpu_count in initsv.ora, 0-use all cores
-- mkdir /oradata/sv and change owner to oracle:oinstall
-- set tablespace size in create_tbs
-- export SQLPATH=$HOME
-- export ORACLE_SID=sv
-- export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
-- export ORACLE_HOME=/oracle/<oracle_version>
-- export PATH=$PATH:$ORACLE_HOME/bin
-- mv initsv.ora to $ORACLE_HOME/dbs
-- put create_db.sql, create_tbs.sql, create_user_main.sql in $HOME
-- run sqlplus / as sysdba
create spfile from pfile;
startup nomount
@create_db;
-- create wallet (only for prod)
alter system set encryption key identified by "Fgb53Bny23c";
--orapki wallet create -wallet /oracle/11.2.0.4/owm/wallets/sv -auto_login -pwd "Fgb53Bny23c"
-- for test/etalon/configuration stand you can use script create_tbs.stand.sql
@create_tbs;
@create_main_user;
