create table mcw_msg_pds (
    msg_id      number(16) not null,
    pds_number  number(4) not null,
    pds_body    varchar2(992)
)
/

comment on table mcw_msg_pds is 'Values of PDSses of messages'
/

comment on column mcw_msg_pds.msg_id is 'Message identifier'
/

comment on column mcw_msg_pds.pds_number is 'PDS number'
/

comment on column mcw_msg_pds.pds_body is 'PDS body'
/

