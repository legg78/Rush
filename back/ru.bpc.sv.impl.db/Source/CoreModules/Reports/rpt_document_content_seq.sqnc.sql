create sequence rpt_document_content_seq 
increment by 1 
start with 1000000000000000
maxvalue   9999999999999999
minvalue   1000000000000000
cache 100
/

drop sequence rpt_document_content_seq
/

create sequence rpt_document_content_seq
  start with 1
  maxvalue 9999999999
  minvalue 1
  cycle
  cache 1000
  noorder
/
