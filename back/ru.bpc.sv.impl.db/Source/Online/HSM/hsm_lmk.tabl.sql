create table hsm_lmk (
    id             number(4) not null
    , seqnum       number(4) not null
    , check_value  varchar2(200) not null
)
/
comment on table hsm_lmk is 'Local Master Key'
/
comment on column hsm_lmk.id is 'LMK identifier'
/
comment on column hsm_lmk.seqnum is 'Sequential number of record version'
/
comment on column hsm_lmk.check_value is 'The LMK check value'
/
