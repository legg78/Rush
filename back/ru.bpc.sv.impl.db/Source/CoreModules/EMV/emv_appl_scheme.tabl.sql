create table emv_appl_scheme (
    id              number(4)  not null
    , seqnum        number(4)
    , inst_id       number(4)
)
/
comment on table emv_appl_scheme is 'Scheme of EMV card applications'
/
comment on column emv_appl_scheme.id is 'Primary key'
/
comment on column emv_appl_scheme.seqnum is 'Sequential number of record data version'
/
comment on column emv_appl_scheme.inst_id is 'Owner institution identifier'
/

alter table emv_appl_scheme add type varchar2(8)
/
comment on column emv_appl_scheme.type is 'EMV scheme identifier (EMVS dictionary)'
/
