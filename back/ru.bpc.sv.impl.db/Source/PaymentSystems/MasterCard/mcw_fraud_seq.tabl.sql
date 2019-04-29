create table mcw_fraud_seq (
   iss_control_number varchar2(7) not null
 , call_date          date        not null
 , seq_number         number(2)   not null
)
/

comment on table mcw_fraud_seq is 'Fraud files (SAFE-files) Sequence Table. This table contains the information about numbers of SAFE-files for Iss Control Nuber in current of day.'
/
comment on column mcw_fraud_seq.iss_control_number is 'Issuer Customer Number'
/
comment on column mcw_fraud_seq.call_date          is 'Call Date'
/
comment on column mcw_fraud_seq.seq_number         is 'Sequential number of safe file to generate today'
/

