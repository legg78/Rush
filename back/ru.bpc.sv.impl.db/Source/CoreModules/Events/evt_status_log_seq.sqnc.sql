create sequence evt_status_log_seq
  start with 1000000000000001
  maxvalue 9999999999999999
  minvalue 1000000000000001
  nocycle
  nocache
  noorder
/

alter sequence evt_status_log_seq cache 1000
/

drop sequence evt_status_log_seq
/

create sequence evt_status_log_seq
  start with 1000000001
  maxvalue 9999999999
  minvalue 1000000001
  cache 1000
  cycle
  noorder
/
