-- create the user 
CREATE USER zabbix
  IDENTIFIED BY zabbix1 
  DEFAULT TABLESPACE system
  TEMPORARY TABLESPACE temp_tbs
  PROFILE DEFAULT;

-- grant role privileges 
GRANT CONNECT TO zabbix;
GRANT RESOURCE TO zabbix;

-- grant object privileges 
GRANT SELECT ON sys.dba_data_files TO zabbix;
GRANT SELECT ON sys.dba_free_space TO zabbix;
GRANT SELECT ON sys.dba_scheduler_jobs TO zabbix;
GRANT SELECT ON sys.dba_tablespaces TO zabbix;
GRANT SELECT ON sys.v_$archived_log TO zabbix;
GRANT SELECT ON sys.v_$instance TO zabbix;
GRANT SELECT ON sys.v_$log TO zabbix;
GRANT SELECT ON sys.v_$loghist TO zabbix;
GRANT SELECT ON sys.v_$session TO zabbix;
GRANT SELECT ON sys.v_$sysstat TO zabbix;
GRANT SELECT ON sys.v_$system_event TO zabbix;

-- grant system privileges 
GRANT CREATE SESSION TO zabbix;
GRANT SELECT ANY DICTIONARY TO zabbix;
GRANT SELECT ANY TABLE TO zabbix;
GRANT UNLIMITED TABLESPACE TO zabbix;
