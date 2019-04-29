create table aup_sv2sv_tech (
    tech_id           varchar2(36)
    , host_id         number(4)
    , iso_msg_type    number(4)
    , direction       number(1)
    , bitmap          varchar2(32)
    , time_mark       varchar2(16)
    , trace           varchar2(6)
    , resp_code       varchar2(8)
    , ntwk_man_code   number(3)
    , part_key        as (to_date('1970.01.01 00:00:00','YYYY.MM.DD HH24:Mi:SS')+(to_number(time_mark)/(24*60*60*1000000))) virtual -- [@skip patch]
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                    -- [@skip patch]
(                                                                                      -- [@skip patch]
    partition aup_sv2sv_tech_p01 values less than (to_date('01-01-2017','DD-MM-YYYY')) -- [@skip patch]
)                                                                                      -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_sv2sv_tech is 'Table is intended to store messages between SV2SV host and switch. Only technical messages are stored.'
/
comment on column aup_sv2sv_tech.tech_id is 'Technical identifier of message'
/
comment on column aup_sv2sv_tech.host_id is 'Host member id identifier for working network host'
/
comment on column aup_sv2sv_tech.iso_msg_type is 'Message type defined by sv2sv protocol'
/
comment on column aup_sv2sv_tech.direction is 'Direction of the message (1 - incoming/0 - outgoing)'
/
comment on column aup_sv2sv_tech.bitmap is 'Message bitmap'
/
comment on column aup_sv2sv_tech.time_mark is 'Time of processing by switch'
/
comment on column aup_sv2sv_tech.trace is 'Trace number, field 11'
/
comment on column aup_sv2sv_tech.resp_code is 'V.I.P. response code, field 39'
/
comment on column aup_sv2sv_tech.ntwk_man_code is 'Network management code/function code, field 24'
/

