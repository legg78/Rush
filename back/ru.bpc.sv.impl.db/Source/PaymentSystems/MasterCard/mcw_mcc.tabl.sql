create table mcw_mcc (
    mcc         varchar2(4)
    , cab_type    varchar2(1)
    , cab_program varchar2(4)
)
/

comment on table mcw_mcc is 'Card Acceptor Business Codes (MCCs)'
/
comment on column mcw_mcc.mcc is 'Card Acceptor Business Code (MCC)'
/
comment on column mcw_mcc.cab_type is 'Card Acceptor Business (CAB) Type'
/
comment on column mcw_mcc.cab_program is 'Card Acceptor Business (CAB) Program'
/
 