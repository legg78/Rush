create table aup_cyberplat (
    auth_id               number(16)
    , part_key            as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual -- [@skip patch]
    , tech_id             varchar2(36)
    , session_id          number(16)
    , paym_aggr_msg_type  varchar2(8)
    , msg_type            varchar2(8)
    , msg_number          number(8)
    , resp                number(8)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH')) -- [@skip patch]
(
    partition aup_cyberplat_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)
******************** partition end ********************/
/

comment on table aup_cyberplat is 'Outgoing messages to cyberplat and responses.'
/
comment on column aup_cyberplat.tech_id is 'Primary key'
/
comment on column aup_cyberplat.auth_id is 'Authorization indentifier'
/
comment on column aup_cyberplat.session_id is 'Cyberplat session identifier'
/
comment on column aup_cyberplat.paym_aggr_msg_type is 'Payment aggregator message type (Request/response,  Payment/Check/Status)'
/
comment on column aup_cyberplat.msg_type is 'Message type (Pre-Authorization, Authorization etc)'
/
comment on column aup_cyberplat.msg_number is 'Number of the message for authorizarion'
/
comment on column aup_cyberplat.resp is 'Response code. Filling only for response messages.'
/
