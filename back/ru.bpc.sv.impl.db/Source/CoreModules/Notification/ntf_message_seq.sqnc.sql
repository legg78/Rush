create sequence ntf_message_seq
maxvalue     9999999999999999
start with   1000000000000001
nocycle
nocache
/
drop sequence ntf_message_seq
/
create sequence ntf_message_seq maxvalue 999999999 start with 1 increment by 1 cache 1000 cycle
/
