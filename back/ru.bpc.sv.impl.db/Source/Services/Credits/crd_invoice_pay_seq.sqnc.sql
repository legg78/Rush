create sequence crd_invoice_pay_seq
  start with 1000000000000001
  maxvalue 9999999999999999
  minvalue 1
  nocycle
  cache 1000
  noorder
/

drop sequence crd_invoice_pay_seq
/
