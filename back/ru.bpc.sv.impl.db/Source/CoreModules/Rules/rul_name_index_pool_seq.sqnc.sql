create sequence rul_name_index_pool_seq 
minvalue 1
maxvalue 9999999999999999
start with 1
increment by 1
nocache
/
alter sequence rul_name_index_pool_seq cache 100000
/