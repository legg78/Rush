create sequence prc_session_file_seq
maxvalue 9999999999
start with   1
increment by 1
cache 50
cycle
/

alter sequence prc_session_file_seq nocycle nocache order
/