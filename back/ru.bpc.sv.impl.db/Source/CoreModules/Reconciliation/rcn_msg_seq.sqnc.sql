create sequence rcn_msg_seq
maxvalue   9999999999999999
start with 1000000000000001
increment by 1
cache 1000
cycle
/
drop sequence rcn_msg_seq
/
create sequence rcn_msg_seq
maxvalue   9999999999
minvalue   1000000001
start with 1000000001
increment by 1
cache 1000
cycle
/
