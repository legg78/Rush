create sequence adt_trail_seq
  start with 1000000000000001
  maxvalue 9999999999999999
  minvalue 1000000000000001
  nocycle
  noorder
  nocache
/
drop sequence adt_trail_seq
/
create sequence adt_trail_seq maxvalue 999999999 start with 1 increment by 1 cache 1000 cycle
/
