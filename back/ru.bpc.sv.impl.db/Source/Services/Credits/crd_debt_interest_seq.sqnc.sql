create sequence crd_debt_interest_seq
  start with 1000000000000001
  maxvalue 9999999999999999
  minvalue 1
  nocycle
  cache 1000
  noorder
/
drop sequence crd_debt_interest_seq
/
create sequence crd_debt_interest_seq maxvalue 9999999999 start with 1 cache 1000 cycle
/
