create sequence ecm_transaction_seq
maxvalue     9999999999
start with   1
cycle
cache 1000
/
drop sequence ecm_transaction_seq
/
create sequence ecm_transaction_seq
maxvalue     4294967295
start with   1000000000
cycle
cache 1000
/
