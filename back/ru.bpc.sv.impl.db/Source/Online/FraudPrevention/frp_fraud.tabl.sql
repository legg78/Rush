create table frp_fraud (
    auth_id         number(16)
  , part_key        as (to_date(substr(lpad(to_char(auth_id), 16, '0'), 1, 6), 'yymmdd')) virtual            -- [@skip patch]
  , entity_type     varchar2(8)
  , object_id       number(16)
  , is_external     number(1)
  , case_id         number(4)
  , event_type      varchar2(8)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition frp_fraud_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))          -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table frp_fraud is 'Registred fraud events.'
/

comment on column frp_fraud.auth_id is 'Reference to authorization marked as fraud.'
/
comment on column frp_fraud.entity_type is 'Entity type fraud is registred for.'
/
comment on column frp_fraud.object_id is 'Object identifier fraud is registred for.'
/
comment on column frp_fraud.is_external is 'External object indicator (1 - external, 0 - own).'
/
comment on column frp_fraud.case_id is 'Reference to fraud case.'
/
comment on column frp_fraud.event_type is 'Exact type of fraud (fraud, suspicion, etc)'
/
alter table frp_fraud add resolution varchar2(8)
/
comment on column frp_fraud.resolution is 'Resolution for fraudulent messages.'
/
alter table frp_fraud add resolution_user_id number(8)
/
comment on column frp_fraud.resolution_user_id is 'Reference to users.'
/
alter table frp_fraud add id number(16)
/
comment on column frp_fraud.id is 'Primary key.'
/
alter table frp_fraud add seqnum number(4)
/
comment on column frp_fraud.seqnum is 'Sequential number of data record version.'
/
