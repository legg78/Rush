create index vis_fraud_CLMS0010_ndx on vis_fraud (
    decode(status, 'CLMS0010', 'CLMS0010', null)
)
/
