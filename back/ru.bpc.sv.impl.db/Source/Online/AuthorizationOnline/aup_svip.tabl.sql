create table aup_svip
(
    tech_id             varchar2(36) not null
    , entity_type       varchar2(8) not null
    , object_id         number(8) not null
    , auth_id           number(16) not null
    , time_mark         varchar2(16) not null
    , message_name      varchar2(30) not null
    , originator_name   varchar2(40)
    , network_ref_ident varchar2(36)
    , client_id_type    varchar2(8)
    , client_id_value   varchar2(200)
    , oper_type         varchar2(8)
    , oper_reason       varchar2(8)
    , client_dt         date
    , oper_amount       number(22,4)
    , oper_currency     varchar2(3)
    , host_dt           date
    , status_code       number(4)
    , part_key          as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aup_svip_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))           -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on column aup_svip.auth_id is 'Identifier authorization that causes message.'
/
comment on column aup_svip.entity_type is 'Type of server entity, i.e. terminal or host.'
/
comment on column aup_svip.object_id is 'Identifier of server entity'
/
comment on column aup_svip.tech_id is 'Technical identifier of message.'
/
comment on column aup_svip.time_mark is 'Time of processing by switch.'
/
comment on column aup_svip.message_name is 'Name of root XML tag in message.'
/
comment on column aup_svip.originator_name is 'Name of originator network.'
/
comment on column aup_svip.network_ref_ident is 'Operation reference number inside foreign network.'
/
comment on column aup_svip.client_id_type is 'Type of cutomer identification.'
/
comment on column aup_svip.client_id_value is 'Customer identification of specified type.'
/
comment on column aup_svip.oper_type is 'Operation type (OPTP).'
/
comment on column aup_svip.oper_reason is 'Operation subtype. Valid values may differ depending on OPTP.'
/
comment on column aup_svip.client_dt is 'Client system date and time.'
/
comment on column aup_svip.oper_amount is 'Amount of operation including fees.'
/
comment on column aup_svip.oper_currency is 'Currency of operation amount.'
/
comment on column aup_svip.host_dt is 'Date processing object on host.'
/
comment on column aup_svip.status_code is 'Code rejection IFX.'
/
alter table aup_svip add (oper_request_amount number(22,4))
/
comment on column aup_svip.oper_request_amount is 'Requested operation amount'
/
alter table aup_svip add (oper_surcharge_amount number(22, 4))
/
comment on column aup_svip.oper_surcharge_amount is 'Amount of operation''s surcharge'
/
alter table aup_svip add (original_auth_id number(16))
/
comment on column aup_svip.original_auth_id is 'Original Id of authorization'
/
