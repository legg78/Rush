create sequence dpp_instalment_seq
  start with 1000000000000001
  maxvalue 9999999999999999
  minvalue 1000000000000001
  nocycle
  nocache
  noorder
/

drop sequence dpp_instalment_seq
/

create sequence dpp_instalment_seq
  start with 1
  maxvalue 9999999999
  minvalue 1
  cycle
  cache 1000
  noorder
/

