create sequence rpt_document_seq
  start with 1
  maxvalue 9999999999999999
  minvalue 1
  nocycle
  nocache
  noorder
/

drop sequence rpt_document_seq
/

create sequence rpt_document_seq
  start with 1
  maxvalue 9999999999
  minvalue 1
  cycle
  cache 1000
  noorder
/
