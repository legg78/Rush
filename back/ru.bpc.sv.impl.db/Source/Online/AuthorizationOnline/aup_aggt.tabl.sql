create table aup_aggt(
    auth_id           number(16,0)
  , part_key          as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual   -- [@skip patch]
  , tech_id           varchar2(36 byte)
  , gate_id           varchar2(16 byte)
  , service_id        varchar2(16 byte)
  , client_id         varchar2(16 byte)
  , time_mark         varchar2(16 byte)
  , payment_datetime  date
  , auth_message      varchar2(6 byte)
  , resp_code         varchar2(6 byte)
)
/****************** partition start ********************
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                        -- [@skip patch]
(                                                                                          -- [@skip patch]
    partition aup_aggt_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))             -- [@skip patch]
)                                                                                          -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_aggt is 'Table is used to store history of messages between Aggregator Gate and switch. Only financial messages are stored'
/
comment on column aup_aggt.auth_id is 'Identifier authorization that causes message'
/
comment on column aup_aggt.tech_id is 'Technical identifier of message'
/
comment on column aup_aggt.time_mark is 'Time of processing by switch'
/
comment on column aup_aggt.gate_id is 'Gate identificator'
/
comment on column aup_aggt.service_id is 'Service identificator'
/
comment on column aup_aggt.client_id is 'Client identificator in service'
/
comment on column aup_aggt.resp_code is 'Response code'
/
comment on column aup_aggt.payment_datetime is 'Payment''s date and time'
/
comment on column aup_aggt.auth_message is 'Message function of authorization state M'
/
alter table aup_aggt modify auth_message varchar2(8)  -- [@skip patch]
/

