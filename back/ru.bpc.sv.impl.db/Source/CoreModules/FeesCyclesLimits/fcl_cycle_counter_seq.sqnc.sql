create sequence fcl_cycle_counter_seq
  start with 1000000000000001
  maxvalue 9999999999999999
  minvalue 1000000000000001
  nocycle
  nocache
  noorder
/
alter sequence fcl_cycle_counter_seq cache 1000
/
