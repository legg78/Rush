create table amx_rejected (
    id                      number(16) not null
    , file_id               number(16)
    , inst_id               number(4) 
    , incoming              number(1) 
    , msg_number            number(8) 
    , forw_inst_code        number(11)
    , receiv_inst_code      number(11)
    , origin_file_id        number(16)
    , origin_msg_id         number(16)
)
/
comment on table amx_rejected is 'Rejected messages'
/
comment on column amx_rejected.id is 'Primary key. Message identifier'
/
comment on column amx_rejected.file_id is 'Rejected file identifier'
/
comment on column amx_rejected.inst_id is 'Institution identifier'
/
comment on column amx_rejected.incoming is '1 – incoming, 0 - outgoing'
/
comment on column amx_rejected.msg_number is 'Message number in rejected file'
/
comment on column amx_rejected.forw_inst_code is 'Forwarding CMID'
/
comment on column amx_rejected.receiv_inst_code is 'Receiving CMID'
/
comment on column amx_rejected.origin_file_id is 'Original file identifier'
/
comment on column amx_rejected.origin_msg_id is 'Original message identifier'
/
