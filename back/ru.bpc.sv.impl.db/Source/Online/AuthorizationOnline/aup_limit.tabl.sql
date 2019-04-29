create table aup_limit(
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
  , auth_id             number(16)
  , limit_type          varchar2(8)
  , entity_type         varchar2(8)
  , object_id           number(16)
  , sum_value           number(22,4)
  , count_value         number(16)
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aup_limit_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))          -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_limit is 'Limits changed by online authorizations.'
/

comment on column aup_limit.id is 'Primary key.'
/
comment on column aup_limit.auth_id is 'Authorization identifier.'
/
comment on column aup_limit.limit_type is 'Limit type.'
/
comment on column aup_limit.entity_type is 'Limit owner entity type.'
/
comment on column aup_limit.object_id is 'Limit owner identifier.'
/
comment on column aup_limit.sum_value is 'Limit sum value.'
/
comment on column aup_limit.count_value is 'Limit count value.'
/
