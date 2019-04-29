create sequence prd_service_object_seq
start with 100000000001
maxvalue 999999999999
nocycle
nocache
/
alter sequence prd_service_object_seq cache 1000
/
