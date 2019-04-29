create sequence acq_reimb_batch_seq
maxvalue     999999999999
start with   1
nocycle
nocache
/
alter sequence  acq_reimb_batch_seq maxvalue 9999999999 cache 10000
/
