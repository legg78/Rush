create table aup_scheme_object
(
    id                  number(16)
  , part_key            as (to_date(substr(lpad(to_char(id), 16, '0'), 1, 6), 'yymmdd')) virtual  -- [@skip patch]
  , seqnum              number(4)
  , scheme_id           number(4)
  , entity_type         varchar2(8)
  , object_id           number(16)
  , start_date          date
  , end_date            date
)
/****************** partition start ********************                                 -- [@skip patch]
partition by range (part_key) interval(numtoyminterval(1, 'MONTH'))                      -- [@skip patch]
(                                                                                        -- [@skip patch]
    partition aci_atm_setl_ttl_p01 values less than (to_date('1-1-2017','DD-MM-YYYY'))   -- [@skip patch]
)                                                                                        -- [@skip patch]
******************** partition end ********************/
/

comment on table aup_scheme_object is 'Authorization schemes linked with business entities.'
/

comment on column aup_scheme_object.id is 'Primary key.'
/
comment on column aup_scheme_object.seqnum is 'Sequential number of data version'
/
comment on column aup_scheme_object.scheme_id is 'Authorization scheme identifier'
/
comment on column aup_scheme_object.entity_type is 'Entity type '
/
comment on column aup_scheme_object.object_id is 'Object identifier'
/
comment on column aup_scheme_object.start_date is 'Start date of validity authorization scheme for that object.'
/
comment on column aup_scheme_object.end_date is 'End date of validity authorization scheme for that object.'
/
