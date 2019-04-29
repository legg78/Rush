create sequence acq_merchant_daily_stat_seq
maxvalue     999999999999
start with   100000000001
nocycle
nocache
/

drop sequence acq_merchant_daily_stat_seq
/

create sequence acq_merchant_daily_stat_seq
maxvalue     9999999999
minvalue     1000000001
start with   1000000001
cache 1000
cycle
noorder
/
