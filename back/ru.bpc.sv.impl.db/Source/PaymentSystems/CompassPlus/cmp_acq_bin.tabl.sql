create table cmp_acq_bin (
    acq_bin             varchar2(20) not null
    , tran_code         varchar2(4)        
)
/
comment on table cmp_acq_bin is 'CMP BINs, depending on compass transaction code.'
/
comment on column cmp_acq_bin.acq_bin is 'Acquirer BIN.'
/
comment on column cmp_acq_bin.tran_code is 'Compass transaction code.'
/
